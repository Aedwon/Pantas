import json, sys
G = json.load(open(sys.argv[1]))[sys.argv[2]]
w = sys.argv[3]
if w == "q":
    print(G["qfile"])
elif w == "c":
    print(G["count"])
else:
    print("; ".join("%s (%s): write %d, key points %d, official items %s" % (p["id"], p["path"], max(0, p["target"]), p["keyPoints"], ", ".join(p["items"])) for p in G["parts"] if p["target"] > 0))
