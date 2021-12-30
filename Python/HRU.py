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
