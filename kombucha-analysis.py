# simple routines for beginning analysis of the kombucha data set

import ubiome

# read all gut files from 'data' directory

import os


# create a single variable that contains all the gut samples

kombucha_gut_samples = ubiome.UbiomeMultiSample()

for root, dirs, files in os.walk("./data"):
    for file in files:
        if file.endswith(".json"):
             print(os.path.join(root, file))
             sample = ubiome.UbiomeSample(fname=os.path.join(root,file))
             if sample.site == "gut":
                 kombucha_gut_samples.merge(sample,mergeField="count")
            # if sample.site == "mouth":  # if you want another variable that contains all mouth samples, etc.

# write to a CSV file like this:
# kombucha_gut_samples.write("kombucha-gut-count.csv")


# plot the data
samples = kombucha_gut_samples.originalSampleObjects
diversity = [sample.diversity() for sample in samples]
dates = [sample.date for sample in samples]

import matplotlib.pyplot as plt

plt.plot(dates,diversity)
plt.ylabel("Diversity (Simpson)")
plt.xticks(dates, [str(date) for date in dates], rotation='vertical')
plt.show()
