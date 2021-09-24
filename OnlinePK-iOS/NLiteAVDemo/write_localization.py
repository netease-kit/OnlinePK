import os
import sys
import re
from pprint import pprint

rootdir = os.path.realpath('.')
src_files = []
for root, subdirs, files in os.walk(rootdir):
	for f in files:
		if os.path.splitext(f)[1] == '.m':
			src_files.append(os.path.join(root,f))

strings = []
for src_file in src_files:
	with open(src_file, 'r') as file:
		data = file.read()
		res = re.findall('(NSLocalizedString\\(@\\"\\S+\\"*\\,\\s?nil\\))', data)
		if (len(res) > 0):
			for str in res:
				if str not in strings:
					strings.append(str)

# pprint(strings)

for str in strings:
	start = str.index("@")+1
	end = str.index("\",")+1
	substr = str[start:end]
	print(substr + " = " + substr + ";")

