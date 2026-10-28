import json, os, sys, time, urllib.parse, urllib.request
import jwt

key_id = os.environ["KEY_ID"]
issuer = os.environ["ISSUER_ID"]
key = open(os.path.expanduser("~/private_keys/AuthKey_%s.p8" % key_id)).read()
now = int(time.time())
token = jwt.encode(
    {"iss": issuer, "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1"},
    key, algorithm="ES256", headers={"kid": key_id, "typ": "JWT"},
)

def get(path):
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path,
                                 headers={"Authorization": "Bearer " + token})
    with urllib.request.urlopen(req) as r:
        return json.load(r)

bundle = os.environ.get("BUNDLE_ID", "").strip()
team = os.environ.get("TEAM_ID", "").strip()

if not bundle:
    apps = get("/v1/apps?limit=200")["data"]
    pick = [a for a in apps if a["attributes"]["name"].lower().replace(" ", "") == "emberfall"]
    if not pick and len(apps) == 1:
        pick = apps
    if len(pick) != 1:
        names = ", ".join("%s (%s)" % (a["attributes"]["name"], a["attributes"]["bundleId"]) for a in apps)
        sys.exit("Could not choose an app. Create an app named Ember Fall in App Store Connect. Found: " + (names or "none"))
    bundle = pick[0]["attributes"]["bundleId"]

if not team:
    q = urllib.parse.urlencode({"filter[identifier]": bundle, "filter[platform]": "IOS"})
    ids = get("/v1/bundleIds?" + q)["data"]
    ids = [i for i in ids if i["attributes"]["identifier"] == bundle]
    if not ids:
        sys.exit("Bundle ID %s not found in the developer account." % bundle)
    team = ids[0]["attributes"]["seedId"]

with open(os.environ["GITHUB_ENV"], "a") as f:
    f.write("BUNDLE_ID=%s\nTEAM_ID=%s\n" % (bundle, team))
print("Using bundle ID %s and team %s" % (bundle, team))
