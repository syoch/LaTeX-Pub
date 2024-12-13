all: all_

# Configuration

PROJECT?=Report-Example
LATEX_ROOT?=$(PROJECT)/main

# Docker

DKRLatexMarker:=.docker/latex.marker
DKRLatexDockerfile:=.docker/latex.Dockerfile
DKRLatexTag:=syoch/texlive
DKRLatex:=docker run -it --rm -v $(PWD)/$(LATEX_ROOT):/work -w /work $(DKRLatexTag)
$(DKRLatexMarker): $(DKRLatexDockerfile)
	docker build -t $(DKRLatexTag) -f $(DKRLatexDockerfile) .docker
	touch $(DKRLatexMarker)

DKRDrawioTag:=rlespinasse/drawio-desktop-headless
DKRDrawio:=docker run -it --rm -v $(PWD):/work -w /work $(DKRDrawioTag)

# Detection

DRAWIO_RESOURCES:=$(shell find $(PROJECT)/res-raw -name "*.drawio")
DRAWIO_PDFS:=$(DRAWIO_RESOURCES:.drawio=.pdf)

PNG_RESOURCES:=$(shell find $(PROJECT)/res-img -name "*.png")
JPG_RESOURCES:=$(shell find $(PROJECT)/res-img -name "*.jpg")
BMP_RESOURCES1:=$(shell find $(PROJECT)/res-img -name "*.bmp")
BMP_RESOURCES2:=$(shell find $(PROJECT)/res-img -name "*.BMP")

PNG_RESOURCES+=$(JPG_RESOURCES:.jpg=.png)
PNG_RESOURCES+=$(BMP_RESOURCES1:.bmp=.png)
PNG_RESOURCES+=$(BMP_RESOURCES2:.BMP=.png)

%.png: %.jpg
	@echo "Converting $< to $@"
	convert $< $@

%.png: %.bmp
	@echo "Converting $< to $@"
	convert $< $@

%.png: %.BMP
	@echo "Converting $< to $@"
	convert $< $@

$(PROJECT)/%.pdf: $(PROJECT)/%.drawio
	@echo "Converting $< to $@"
	$(DKRDrawio) --crop -xf pdf -o $@ $<

RESOURCES+=$(DRAWIO_PDFS)
RESOURCES+=$(PNG_RESOURCES)

# Resource/Graph
CSV_RESOURCES:=$(shell find $(PROJECT)/data -name "*.csv")
$(PROJECT)/data/%/table.tex: $(PROJECT)/data/%/table.csv
	@echo "Converting $< to $@"
	python3 scripts/csv_to_tex.py $< $@

TEX_TARGETS+=$(patsubst $(PROJECT)/data/%/table.csv,$(PROJECT)/data/%/table.tex,$(CSV_RESOURCES))

%/table.eps: $(wildcard %/*.plot) %/commands.gplot
	@echo "Converting $< to $@"
	cd $(dir $<) && gnuplot commands.gplot

GRAPH_RESOURCES:=$(patsubst $(PROJECT)/data/%/commands.gplot,$(LATEX_ROOT)/%.eps,$(shell find $(PROJECT)/data -name "commands.gplot"))
$(LATEX_ROOT)/%.eps: $(PROJECT)/data/%/table.eps
	@echo "Copying $< to $@"
	cp $< $@

.PHONY: copy_graph
copy_graph: $(GRAPH_RESOURCES)

# Resources

.PHONY: copy_res
copy_res: $(TEX_TARGETS) $(RESOURCES) copy_graph
	if [ ! -z "$(strip $(RESOURCES))" ]; then cp $(strip $(RESOURCES)) $(LATEX_ROOT); fi

# Latex

LATEX_AUX:=$(LATEX_ROOT)/template.aux

$(LATEX_AUX): .docker/latex.marker $(LATEX_ROOT)/template.tex copy_res
	@echo aux
	$(DKRLatex) uplatex template.tex

$(LATEX_ROOT)/template.pdf: .docker/latex.marker $(LATEX_AUX) $(LATEX_ROOT)/template.dvi
	@echo Make PDF
	$(DKRLatex) dvipdfmx template.dvi

.PHONY: make_pdf
make_pdf: $(LATEX_ROOT)/template.pdf

# Rules

clean:
	rm -f $(RESOURCES) $(LATEX_ROOT)/*.aux $(LATEX_ROOT)/*.dvi $(LATEX_ROOT)/*.log $(LATEX_ROOT)/*.pdf

all_: $(RESOURCES) $(GRAPH_RESOURCES) _make_pdf

.PHONY: _make_pdf
_make_pdf:
	@echo "===== Start ===== "
	@# makes n times until make returns -1
	@while ! make compile; do :; done
	@$(MAKE) make_pdf
	@echo "===== Done ===== "

.PHONY: compile
compile: $(LATEX_ROOT)/template.aux

# Utility
.PHONY: new
new:
	if [ -z $(NAME) ]; then echo "NAME is not set"; exit 1; fi
	if [ -d $(NAME) ]; then echo "$$NAME already exists"; else mkdir $(NAME); fi

	cp -r .template/* $(NAME)
	code $(NAME)/main/template.tex