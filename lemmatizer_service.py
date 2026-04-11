from flask import Flask, request, jsonify
import spacy
import unicodedata

app = Flask(__name__)
nlp = spacy.load("fr_dep_news_trf")

def remove_accents(text):
    return ''.join(
        c for c in unicodedata.normalize('NFD', text)
        if unicodedata.category(c) != 'Mn'
    )

@app.route("/lemmatize", methods=["POST"])
def lemmatize():
    data = request.get_json()
    text = data.get("text", "")
    doc = nlp(text)
    lemmas = [
        remove_accents(token.lemma_.lower())
        for token in doc
        if not token.is_punct and not token.is_space
    ]
    return jsonify({"lemmas": lemmas})

if __name__ == "__main__":
    app.run(port=5001)