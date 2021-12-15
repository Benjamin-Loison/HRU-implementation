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
    objects += [Xo]
    
def createSubject(Xs):
    subjects += [Xs]

def delete(right, subject, object = DEFAULT):
    key = getKey(subject, object)
    if key in currentRights:
        if right in currentRights[key]:
            currentRights[key].remove(right)

#def checkGoal(scriptName):
#    global currentRights
scriptName = 'Share'#'Share' # otherwise using checkGoal function involves bugs
fileName = scriptName + '.py'
f = open(fileName)
linesStr = f.read()
f.close()
lines = linesStr.splitlines()

currentRights, commands, objects, subjects = {}, {}, [], []

for line in lines:
    if line.startswith('def '):
        line = line.replace('def ', '')
        lineParts = line.split('(')
        command = lineParts[0]
        if command == 'goal':
            continue
        arguments = lineParts[1].split(')')[0].replace(' ', '').split(',')
        commands[command] = arguments

exec(linesStr)

rightsLen = len(rights)
t = [list(combinations(rights, i)) for i in range(rightsLen)]
rightsCombinaisons = [item for sublist in t for item in sublist]
initialCurrentRights = deepcopy(currentRights)
commandsNumber = 0
noThreat = True

# could still make IntermediaryApp be different at each command or should force no new permission given to the IntermediaryApp except if the script adds it
while noThreat:
    commandsCombinaison = [p for p in product(commands, repeat=commandsNumber)]
    allRightsCombinaisons = list(product(*[rightsCombinaisons for i in range(commandsNumber)]))
    
    for allRightsCombinaisonsIndex in range(len(allRightsCombinaisons)):
        currentRights = deepcopy(initialCurrentRights)
        allRightsCombinaison = allRightsCombinaisons[allRightsCombinaisonsIndex]
        #print('testing', commandsCombinaison, allRightsCombinaison)
        for commandsIndex in range(commandsNumber):
            command = commandsCombinaison[0][commandsIndex]
            arguments = commands[command]
            for right in allRightsCombinaison[commandsIndex]:
                enter(right, arguments[0])
            exec(command + '(' + ', '.join(['"' + argument + '"' for argument in arguments]) + ')')
        if goal():
            print('goal reached for:', commandsCombinaison, allRightsCombinaison)
            noThreat = False
            break
    commandsNumber += 1

#scripts = ['Share', 'Pileup']
#for script in scripts:
#    checkGoal(script)