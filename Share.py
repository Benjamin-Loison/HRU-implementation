# could make a pre interpretation to make it easier
SendInternetR = "SendInternetR"
ShareReceive = "ShareReceive"
ShareSend = "ShareSend"

rights = [SendInternetR, ShareReceive, ShareSend]

App = "App"
enter(ShareSend, App)

def sendInternet(IntermediaryApp):
    if has(SendInternetR, App):
        pass
    elif has(SendInternetR, IntermediaryApp) and has(ShareReceive, IntermediaryApp) and has(ShareSend, App):
        enter(SendInternetR, App)

def goal():
    return has(SendInternetR, App)
