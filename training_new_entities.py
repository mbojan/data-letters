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

import os
import sys

# new entity label
LABEL = ['DATE','ROLE','TYPE','AFF']

# training data
# Note: If you're using an existing model, make sure to mix in examples of
# other entity types that spaCy correctly recognized before. Otherwise, your
# model might learn the new type, but "forget" what it previously knew.
# https://explosion.ai/blog/pseudo-rehearsal-catastrophic-forgettingin_data(path_to_files):
    
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


plac.annotations(
    model=("Model name. Defaults to blank 'en' model.", "option", "m", str),
    new_model_name=("New model name for model meta.", "option", "nm", str),
    output_dir=("Optional output directory", "option", "o", Path),
    n_iter=("Number of training iterations", "option", "n", int))
def main(model='pt', new_model_name='pt_new_ners', output_dir='trained_models/pt_new_ners', n_iter=20):
    """Set up the pipeline and entity recognizer, and train the new entity."""
    if model is not None:
        nlp = spacy.load(model)  # load existing spaCy model
        print("Loaded model '%s'" % model)
    else:
        nlp = spacy.blank('pt')  # create blank Language class
        print("Created blank 'pt' model")

    # Add entity recognizer to model if it's not in the pipeline
    # nlp.create_pipe works for built-ins that are registered with spaCy
    if 'ner' not in nlp.pipe_names:
        ner = nlp.create_pipe('ner')
        nlp.add_pipe(ner)
    # otherwise, get it, so we can add labels to it
    else:
        ner = nlp.get_pipe('ner')

    for label in LABEL:
        ner.add_label(label)   # add new entity label to entity recognizer

    # get names of other pipes to disable them during training
    other_pipes = [pipe for pipe in nlp.pipe_names if pipe != 'ner']
    with nlp.disable_pipes(*other_pipes):  # only train NER
        optimizer = nlp.begin_training()
        for itn in range(n_iter):
            random.shuffle(TRAIN_DATA)
            losses = {}
            for text, annotations in TRAIN_DATA:
                nlp.update([text], [annotations], sgd=optimizer, drop=0.35,
                           losses=losses)
            print(losses)

    # test the trained model
    test_text = ' 229-  1722, Maio, 28, Lisboa AVISO do secretário de estado, Diogo de Mendonça Corte Real ao governador do Rio de Janeiro, Aires de Saldanha de Albuquerque, ordenando que se dêem os despachos necessários sobre a carta do ouvidor-geral do Rio das Velhas, José de Sousa Valdez e sobre as razões por que soltou os soldados sem serem castigados pelo que fizeram contra o capitão-mor de Vila Real, Lucas Ribeiro de Almeida.'
    doc = nlp(test_text)
    print("Entities in '%s'" % test_text)
    for ent in doc.ents:
        print(ent.label_, ent.text)

    # save model to output directory
    if output_dir is not None:
        output_dir = Path(output_dir)
        if not output_dir.exists():
            output_dir.mkdir()
        nlp.meta['name'] = new_model_name  # rename model
        nlp.to_disk(output_dir)
        print("Saved model to", output_dir)

        # test the saved model
        print("Loading from", output_dir)
        nlp2 = spacy.load(output_dir)
        doc2 = nlp2(test_text)
        for ent in doc2.ents:
            print(ent.label_, ent.text)


if __name__ == '__main__':
    plac.call(main)
