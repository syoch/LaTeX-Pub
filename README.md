# LaTeX-DevContainer

`*.tex` ファイルを DevContainer 内でビルドできる環境を提供します。

## 使い方

### Gnuplot

`data/xxx/commands.gplot` ファイルに記述された Gnuplot コマンドを実行し、その結果を `xxx.eps` というファイル名で生成します。生成されたファイルは、自動的に `main` ディレクトリにコピーされます。

### CSV to LaTeX

`data/xxx/table.csv` を作成して保存すると、LaTeXの表環境ソース (tabular) のテンプレートが自動生成されます。出力先は `data/xxx/table.tex` です。

CSV ファイルの書式は以下の例を参照してください。

```csv
__meta__,title   ,表のデモ
__meta__,columns ,ccc
__special__,hline
a, b, c
__special__,hline
1, 2, 3
2, 3, 4
```
