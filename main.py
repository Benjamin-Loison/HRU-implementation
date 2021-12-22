#!/usr/bin/python3

from os import chdir
from copy import deepcopy
from itertools import combinations, product

path = '/home/benjamin/Desktop/M1/InitiationResearch/Security/HRU-implementation/'

chdir(path)

# would be very great if got a "trivial" modelisation leading to a goal reached with a very complex "solution"

DEFAULT = "Default"

def getKey(subject, object):
    return subject + '-' + object

def has(right, subject, object = DEFAULT):
    key = getKey(subject, object)
    if key in currentRights:
        l = currentRights[key]
        if right in l:
            return True
    return False
    
def enter(right, subject, object = DEFAULT):
    key = getKey(subject, object)
    if key in currentRights:
        if not right in currentRights[key]:
            currentRights[key] += [right]
    else:
        currentRights[key] = [right]

def createObject(Xo):
    global objects
    objects += [Xo]
    
def createSubject(Xs):
    global subjects
    subjects += [Xs]

def delete(right, subject, object = DEFAULT):
    key = getKey(subject, object)
    if key in currentRights:
        if right in currentRights[key]:
            currentRights[key].remove(right)

scriptName = 'Pileup'#'Share'
fileName = scriptName + '.py'
f = open(fileName)
linesStr = f.read()
f.close()
lines = linesStr.splitlines()

currentRights, commands, objects, subjects = {}, {}, [], []

for linesIndex in range(len(lines)):
    line = lines[linesIndex]
    if line.startswith('def '):
        line = line.replace('def ', '')
        lineParts = line.split('(')
        command = lineParts[0]
        if command == 'goal' or lines[linesIndex - 1].startswith("# manual"):
            continue
        arguments = lineParts[1].split(')')[0].replace(' ', '').split(',')
        commands[command] = arguments

exec(linesStr)

commandsNumber = 0
noThreat = True

while noThreat:
    commandsCombinaison = [p for p in product(commands, repeat=commandsNumber)]
    
    print('testing', commandsCombinaison)
    for commandsIndex in range(commandsNumber):
        command = commandsCombinaison[0][commandsIndex]
        arguments = commands[command]
        
        exec(command + '(' + ', '.join(['"' + argument + '"' for argument in arguments]) + ')')
    if goal():
        print('goal reached for:', commandsCombinaison)
        noThreat = False
        break
    commandsNumber += 1
