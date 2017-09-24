# GEO-Importer
A bulk import script that reads a .txt file from iTMS, brings in and saves each column of the text file into multiple arrays. It will then search that cusotmers folder for each item in the array and will copy the GEO to the specified directory. Ready to be bulk imported into Tops Nest.

## Getting Started

You will need a .txt file for the script to scrape all the information from. Formatted like "JobNumber - Customer Name.txt". I am using a .txt file exported from iTMS that has all the information needed. Place this .txt file in the same location as the script. Change directoires to where the script is located and in the terminal run,

```
$ ./GEO-Importer.sh JobNumber - Customer Name.txt
```

### Prerequisites

What things you need to install the software and how to install them

```
dos2unix

debian based distros:
$ sudo apt install dos2unix
```

### Installing

Copy the script to your home directory preferably its own folder and make the script executable

```
Change into the directory where the script is located,
$ cmod +x GEO-Importer.sh
```
