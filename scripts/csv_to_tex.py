def check_file_exists(filename: str):
    import os

    if not os.path.exists(filename):
        return False
    return True


def format_elem(elem: str) -> str:
    prefixes = []
    suffixes = []

    if elem.startswith("@"):
        tokens = elem.split("$")
        for token in tokens:
            if token.startswith("m"):
                columns = int(token[1:])
                prefixes.append(f"\\multicolumn{{{columns}}}{{c}}{{")
                suffixes.append("}")

    return "".join(prefixes) + elem + "".join(suffixes)


def table_column(row: list[str]) -> str:
    if row[0] == "__special__":
        if row[1] == "hline":
            return "\\hline"
    if row[0] == "":
        return ""

    return " & ".join(format_elem(elem) for elem in row) + " \\\\"


def convert_csv_to_tex(input_data: list) -> list[str]:
    raw_table: list[list[str]] = []
    for line in input_data:
        row = []
        for data in line.strip().split(","):
            row.append(data.strip())

        if not row:
            continue

        raw_table.append(row)

    meta = {row[1]: row[2] for row in raw_table if row[0] == "__meta__"}

    table = [row for row in raw_table if row[0] != "__meta__"]

    table_size_height = len(table)
    table_size_width = max(len(row) for row in table)

    title = meta.get("title", "__________")
    columns = meta.get("columns", "|".join(["c"] * table_size_width))

    return [
        "\\begin{table}[hbtp]",
        f"  \\caption{{{title}}} \\label{{tab: {title}}}",
        "  \\centering",
        "  \\renewcommand{\\arraystretch}{0.7}",
        f"  \\begin{{tabular}}{{{columns}}}",
        *[table_column(row) for row in table],
        "    \\hline",
        "  \\end{tabular}",
        "\\end{table}",
    ]


def cli_main():
    import sys

    if len(sys.argv) != 3:
        print("Usage: python csv_to_tex.py <input> <output>")
        sys.exit(1)

    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    if not check_file_exists(input_filename):
        print(f"Error: {input_filename} does not exist")
        sys.exit(1)

    with open(input_filename, "r") as f:
        input_data = f.readlines()

    output_data = convert_csv_to_tex(input_data)

    with open(output_filename, "w") as f:
        f.write("\n".join(output_data))


if __name__ == "__main__":
    cli_main()
