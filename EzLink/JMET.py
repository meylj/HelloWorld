import uuid
import urllib
import httplib
import os
import string
import sys

url = 'http://prov:8080/TREECKO/controller'
params = sys.argv[1]

headers = {"Content-type":"application/x-www-form-urlencoded","Accept":"text/plain"}
conn = httplib.HTTPConnection('prov:8080')
conn.request("POST", url,params,headers)

res = conn.getresponse()
rlt = res.read()
print rlt