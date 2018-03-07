import io
import os
from bitcoinrpc.authproxy import AuthServiceProxy


def ParseConfig(fileBuffer):
    assert type(fileBuffer) is type(b'')
    f = io.StringIO(fileBuffer.decode('ascii', errors='ignore'), newline=None)
    result = {}
    for line in f:
        assert type(line) is type(b''.decode())
        stripped = line.strip()
        if stripped.startswith('#'):
            continue
        if stripped == '':
            continue
        parts = stripped.split('=')
        assert len(parts) == 2
        parts[0] = parts[0].strip()
        parts[1] = parts[1].strip()
        result[parts[0]] = parts[1]
    return result


# fix lib pathing - cwd only for now
def Connect():
    home = os.path.expanduser("~")
    with open(os.path.join(home,'.bitcloud','bitcloud.conf'), mode='rb') as f:
        configFileBuffer = f.read()
    config = ParseConfig(configFileBuffer)
    protocol = 'http'
    if 'rpcssl' in config and bool(config['rpcssl']) and int(config['rpcssl']) > 0:
        protocol = 'https'
    serverURL = protocol + '://' + config['rpcuser'] + ':' + config['rpcpassword'] + \
        '@127.0.0.1:' + str(config['rpcport'])
    return AuthServiceProxy(serverURL)

def getrpc():
    return Connect()

