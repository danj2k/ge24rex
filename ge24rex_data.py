# Python program to create data file for GE24 Results Explorer

import openpyxl
import pprint
from hexdump import hexdump
import copy

def custom_split(text: str):
    result = []
    current_word = ""
    for c in text:
        match c:
            case " ":
                if current_word != "":
                    result.append(current_word)
                    current_word = ""
            case "," | "-":
                if current_word != "":
                    result.append(current_word)
                result.append(c)
                current_word = ""
            case _:
                current_word = current_word + c
    if current_word != "":
        result.append(current_word)
    return result

wb_obj = openpyxl.load_workbook("Winning-members-(Friday-1720).xlsx")

sheet_obj = wb_obj.active

range_obj = sheet_obj['B2':'B650']

constituency_dict = []
for cell_obj in range_obj:
    cell, = cell_obj
    split_cons = custom_split(cell.value)
    for word in split_cons:
        if word not in constituency_dict:
            constituency_dict.append(word)

constituency_dict.sort()

range_obj = sheet_obj['H2':'H650']

party_dict = []
for cell_obj in range_obj:
    cell, = cell_obj
    if cell.value not in party_dict:
        party_dict.append(cell.value)
party_dict.sort()
print(str(len(party_dict)) + " political parties.")

output_dict = party_dict.copy()
output_dict.extend(constituency_dict)

total_characters = 0
output_array = []
for entry in output_dict:
    index_pointer = total_characters
    total_characters = total_characters + len(entry) + 1 # don't forget we'll need terminating characters as well
    for c in entry:
        output_array.append(ord(c))
    output_array.append(13)

range_obj = sheet_obj['B2':'B650']
constituencies = []
for cell_obj in range_obj:
    cell, = cell_obj
    constituencies.append(cell.value)

range_obj = sheet_obj['B2':'G650']
cons_result_array = []
for row_obj in range_obj:
    cons_cell, _, _, _, _, res_cell = row_obj
    cons_result = res_cell.value.split()
    match cons_result:
        case [winner, 'hold']:
            # lookup winner in output_dict
            win_num = output_dict.index(winner) + 1 # so we can detect if there's a hold
            res_num = win_num
        case [winner, 'gain', 'from', loser]:
            # lookup winner and loser in output_dict
            win_num = output_dict.index(winner) + 1 # so we can detect if there's a hold
            loss_num = output_dict.index(loser) + 1 # so we can detect if there's a hold
            res_num = (loss_num << 4) + win_num
    cons_result_array.append(res_num)
    num_pointers = len(custom_split(cons_cell.value))
    cons_result_array.append(num_pointers)
    for word in custom_split(cons_cell.value):
        cons_result_array.append(0)
        cons_result_array.append(0)

party_pointer_array = []
for party in party_dict:
    party_pointer_array.append(0)
    party_pointer_array.append(0)

index_pointer = 2 + (len(constituencies)*2) + len(cons_result_array) + len(party_pointer_array)
output_index_pointers = []
for entry in output_dict:
    temp_index_pointer = index_pointer.to_bytes(2, 'little')
    output_index_pointers.append(int(temp_index_pointer[0]))
    output_index_pointers.append(int(temp_index_pointer[1]))
    index_pointer = index_pointer + len(entry) + 1

# now put the pointers into the constituency/result array
old_cons_result_array = cons_result_array.copy()
cons_result_array = []
cons_index = 0
cons_pointer_array = []
cons_pointer = 2 + (len(constituencies)*2)
while len(old_cons_result_array) > 0:
    result = old_cons_result_array.pop(0)
    cons_length = old_cons_result_array.pop(0)
    cons_result_array.append(result)
    cons_result_array.append(cons_length)
    for i in range(cons_length):
        _ = old_cons_result_array.pop(0)
        _ = old_cons_result_array.pop(0)
    for word in custom_split(constituencies[cons_index]):
        entry_num = output_dict.index(word)
        cons_result_array.append(output_index_pointers[entry_num*2])
        cons_result_array.append(output_index_pointers[(entry_num*2)+1])
    cons_index = cons_index + 1
    temp_cons_pointer = cons_pointer.to_bytes(2, 'little')
    cons_pointer_array.append(int(temp_cons_pointer[0]))
    cons_pointer_array.append(int(temp_cons_pointer[1]))
    cons_pointer = cons_pointer + 2 + (cons_length * 2)

party_pointer_array = []
for party in party_dict:
    entry_num = output_dict.index(party)
    party_pointer_array.append(output_index_pointers[entry_num*2])
    party_pointer_array.append(output_index_pointers[(entry_num*2)+1])

party_pointer_pointer = 2 + (len(constituencies)*2) + len(cons_result_array)
temp_ppp = party_pointer_pointer.to_bytes(2, 'little')
data_array = []
data_array.append(int(temp_ppp[0]))
data_array.append(int(temp_ppp[1]))
data_array.extend(cons_pointer_array)
data_array.extend(cons_result_array)
data_array.extend(party_pointer_array)
data_array.extend(output_array)

byte_array = bytearray(data_array)

print(str(len(output_dict)) + " entries in dictionary")
print(str(total_characters) + " characters total")
print("Constituency and result data is " + str(len(byte_array)) + " bytes total")

hexdump(byte_array)

with open("ge24dat.dat", "wb") as binary_file:
    binary_file.write(byte_array)

wb_obj.close()