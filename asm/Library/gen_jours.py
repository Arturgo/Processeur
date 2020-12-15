def Bin(a):
	if a==0:
		return '0'
	return (bin(a)[2:])[::-1]

nbJours = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

for year in range(0, 400):
	for month in range(0, 11):
		nJours = nbJours[month]
		
		if month == 1:
			if year != 0 and year % 100 != 0 and year % 4 == 0:
				nJours += 1
		
		for day in range(0, nJours):
			print("{:0<32}".format(Bin(day)))
			print("{:0<32}".format(Bin(month)))
			print("{:0<32}".format(Bin(year)))
			
