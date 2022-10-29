import re

variable_regex = re.compile('var.([a-zA-Z_0-9]*)[\W|\s]*')

with open('new_main.tf', 'w') as write_f:
    with open('main.tf', encoding="utf-8") as read_f:
        for line in read_f:
            new_line = line
            variable_matches = variable_regex.findall(line.strip())
            if variable_matches is not None and len(variable_matches) > 0:
                for v in variable_matches:
                    new_line = new_line.replace(f'var.{v}', f'var.vpc.{v}')
            write_f.write(f'{new_line}')