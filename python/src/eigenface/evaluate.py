from sklearn.metrics import accuracy_score, confusion_matrix

def evaluate_model(model, manifest):
    truths=[]; predictions=[]
    for row in manifest.itertuples(index=False):
        result=model.predict(row.path); truths.append(row.subject); predictions.append(result.identity or "UNKNOWN")
    classes=sorted(set(truths)|set(predictions)); matrix=confusion_matrix(truths,predictions,labels=classes)
    recognized=sum(p!="UNKNOWN" for p in predictions); correct=sum(t==p for t,p in zip(truths,predictions))
    return {"total":len(truths),"recognized":recognized,"rejected":len(truths)-recognized,"correct":correct,"accuracy":accuracy_score(truths,predictions) if truths else 0.0,"classes":classes,"confusion_matrix":matrix}
