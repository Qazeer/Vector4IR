fields_csv_header = ''

i = 0
for field in fields_csv_header.split(','):
    field_key = field.lower().replace(' ', '').replace('"', '').replace('/', '_')
    print(f'.{field_key} = fields[{i}]')
    i = i + 1
