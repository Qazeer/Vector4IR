fields_csv_header = ''

i = 0
for field in fields_csv_header.split(','):
    print(f'.{field.lower()} = fields[{i}]')
    i = i + 1
