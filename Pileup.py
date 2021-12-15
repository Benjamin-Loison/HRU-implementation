Exists = "Exists"
Has = "Has"
Authorized = "Authorized"
Requested = "Requested"
ShouldExist = "ShouldExist"

PermControl = 'PermControl'
#Objects: P
#Subjects: A, PermControl

rights = [Exists, Has, Authorized, Requested, ShouldExist]

def getA():
    Acopy = subjects.copy()
    Acopy.remove(PermControl)
    return Acopy

def installApp(a, P):
    createSubject(a)
    for p in P:
        if has(Exists, PermControl, p):
            enter(Authorized, a, p)
            enter(Has, a, p)
        else:
            createObject(p)
        enter(Requested, a, p)

# P2 can be new permissions or all permissions (with adding the new ones) if old it will pass for them
def installNewVersion(P2):
    for p in P2:
        if has(Exists, PermControl, p):
            pass
        else:
            for a in getA():
                if has(Requested, a, p):
                    enter(ShouldExist, PermControl, p)
                    enter(Has, a, p)
            if has(ShouldExist, PermControl, p):
                delete(ShouldExist, PermControl, p)
            else:
                createObject(p)
            enter(Exists, PermControl, p)

def goal():
    return any([has(Has, a, p) and not has(Authorized, a, p) for p in objects for a in getA()])
