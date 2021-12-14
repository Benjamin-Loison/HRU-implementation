import os, itertools

path = '/home/benjamin/Desktop/M1/InitiationResearch/Security/HRU-implementation/'

os.chdir(path)

fileName = 'Share.py'
f = open(fileName)
linesStr = f.read()
f.close()
lines = linesStr.splitlines()

DEFAULT = "Default"

currentRights = {}

def getKey(subject, object):
    return subject + '-' + object

def has(right, subject, object = DEFAULT):
    key = getKey(subject, object)
    if key in currentRights:
        l = currentRights[key]
        for el in l:
            if el == right:
                return True
    return False
    
def enter(right, subject, object = DEFAULT):
    key = getKey(subject, object)
    if key in currentRights:
        currentRights[key] += [right]
    else:
        currentRights[key] = [right]

subjects = []

commands = []

def startsWith(haystack, needle):
    return haystack[:len(needle)] == needle

for line in lines:
    if startsWith(line, 'def '):
        line = line.replace('def ', '')
        lineParts = line.split('(')
        command = lineParts[0]
        arguments = lineParts[1].split(')')[0].replace(' ', '').split(',')
        commands += [[command, arguments]]

#print(commands)

exec(linesStr)

rightsLen = len(rights)
t = [list(itertools.combinations(rights, i)) for i in range(rightsLen)]
rightsCombinaisons = [item for sublist in t for item in sublist]
#print(rightsCombinaisons)
rightsCombinaisonsLen = len(rightsCombinaisons)

initialCurrentRights = currentRights.copy()

for rightsCombinaisonsIndex in range(rightsCombinaisonsLen):
    rightsCombinaison = rightsCombinaisons[rightsCombinaisonsIndex]
    currentRights = initialCurrentRights.copy()
    command, argument = commands[0]
    for right in rightsCombinaison:
        enter(right, argument[0])
    exec(command + '("' + argument[0] + '")')
    if goal():
        print('threat found for:', rightsCombinaison)
        break
