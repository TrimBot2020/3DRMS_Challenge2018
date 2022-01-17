#!/bin/bash

# download
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2018_gt.tgz
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2018_results.tgz
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2018_training.tgz
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2018_testing.tgz
wget https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/Challenge2018_validation.tgz

# extract
tar --extract --file Challenge2018_gt.tgz
tar --extract --file Challenge2018_training.tgz
tar --extract --file Challenge2018_testing.tgz
tar --extract --file Challenge2018_results.tgz
tar --extract --file Challenge2018_validation.tgz


