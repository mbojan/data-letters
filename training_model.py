#!/usr/bin/env python
# coding: utf8
"""
For more details, see the documentation:
* Training: https://spacy.io/usage/training
* NER: https://spacy.io/usage/linguistic-features#named-entities
Compatible with: spaCy v2.0.0+
"""
from __future__ import unicode_literals, print_function

import plac
import random
from pathlib import Path
import spacy
import sys
import os

# training data
def get_train_data(path_to_files):
    TRAIN_DATA = []
    
    reload(sys)  
    sys.setdefaultencoding('utf8')

    #testing a few files
    for document in os.listdir(path_to_files):
        f = open(path_to_files+'/'+document,'r')
        text = f.readline().decode('utf-8')
        ent = {'entities':[]}
        for line in f:
            ps = [pos for pos, char in enumerate(line) if char == ';'] #positions of ';'
            if ps:
                if line[ps[2]+2:-2] == 'MISC':
                    continue
                else:
                    ent_tuple = (int(line[ps[0]+2:ps[1]]), int(line[ps[1]+2:ps[2]]), line[ps[2]+2:-2])
                    ent['entities'].append(ent_tuple)

        train_tuple = (text, ent)

        TRAIN_DATA.append(train_tuple)
        
        f.close()
    return TRAIN_DATA


TRAIN_DATA = get_train_data('train_poi_data_maxqda')
print(TRAIN_DATA)
print(' ')

@plac.annotations(
    model=("Model name. Defaults to blank 'en' model.", "option", "m", str),
    output_dir=("Optional output directory", "option", "o", Path),
    n_iter=("Number of training iterations", "option", "n", int))

def main(model='trained_models/pt_new_ners', output_dir='trained_models/pt_exist_af', n_iter=100):
    """Load the model, set up the pipeline and train the entity recognizer."""
    if model is not None:
        nlp = spacy.load(model)  # load existing spaCy model
        print("Loaded model '%s'" % model)
    else:
        nlp = spacy.blank('pt')  # create blank Language class
        print("Created blank 'pt' model")

    # create the built-in pipeline components and add them to the pipeline
    # nlp.create_pipe works for built-ins that are registered with spaCy
    if 'ner' not in nlp.pipe_names:
        ner = nlp.create_pipe('ner')
        nlp.add_pipe(ner, last=True)
    # otherwise, get it so we can add labels
    else:
        ner = nlp.get_pipe('ner')

    # add labels
    for _, annotations in TRAIN_DATA:
        for ent in annotations.get('entities'):
            ner.add_label(ent[2])

    # get names of other pipes to disable them during training
    other_pipes = [pipe for pipe in nlp.pipe_names if pipe != 'ner']
    with nlp.disable_pipes(*other_pipes):  # only train NER
        optimizer = nlp.begin_training()
        for itn in range(n_iter):
            random.shuffle(TRAIN_DATA)
            losses = {}
            for text, annotations in TRAIN_DATA:
                nlp.update(
                    [text],  # batch of texts
                    [annotations],  # batch of annotations
                    drop=0.5,  # dropout - make it harder to memorise data
                    sgd=optimizer,  # callable to update weights
                    losses=losses)
            print(losses)

    # test the trained model
    for text, _ in TRAIN_DATA:
        doc = nlp(text)
        print('Entities', [(ent.text, ent.label_) for ent in doc.ents])
        print('Tokens', [(t.text, t.ent_type_, t.ent_iob) for t in doc])

    # save model to output directory
    if output_dir is not None:
        output_dir = Path(output_dir)
        if not output_dir.exists():
            output_dir.mkdir()
        nlp.to_disk(output_dir)
        print("Saved model to", output_dir)

        # test the saved model
        print("Loading from", output_dir)
        nlp2 = spacy.load(output_dir)
        for text, _ in TRAIN_DATA:
            doc = nlp2(text)
            print('Entities', [(ent.text, ent.label_) for ent in doc.ents])
            print('Tokens', [(t.text, t.ent_type_, t.ent_iob) for t in doc])


if __name__ == '__main__':
    plac.call(main)
