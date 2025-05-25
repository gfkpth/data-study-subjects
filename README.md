# Introduction

This repository imports, cleans and collects some datasets regarding the number of students in Germany over time based on publicly available data from the [Federal Statistical Office](https://www-genesis.destatis.de/).


# Relevant files

- The current and most readable version of the data cleanup and analysis processes can be found in the jupyter notebook [core_EDA.ipynb](core_EDA.ipynb). This also contains the links to all the raw datasets.
- An older version of the notebook documenting some pre-work can be found in [process_documentation_EDA.ipynb](process_documentation_EDA.ipynb).
- A brief Beamer presentation (including the basic markdown file, thanks [pandoc](https://pandoc.org/)!) on the methodology, challenges and some select findings is available in [presentation/](presentation/).
- The cleaned datasets generated and the sqlite database can be found in [datasets/](datasets/). The raw datasets are also available in the subfolder [raw/](datasets/raw/).
- There are also two JSON files for mappings of subject codes to subject clusters and subject groups extracted from the official taxonomies, which I have only been able to find in pdf format. The JSON files also contain English translation for all subject, cluster and group names.
  - pdf: [subject codes for courses of study](https://www.destatis.de/DE/Methoden/Klassifikationen/Bildung/studenten-pruefungsstatistik.pst_all?__blob=publicationFile&v=12)
  - pdf: [subject codes for personnel organisation](https://www.destatis.de/DE/Methoden/Klassifikationen/Bildung/personal-stellenstatistik.pdf?__blob=publicationFile&v=14)
- [sql-quests.sql](sql-queries.sql) is an SQL script for running several queries on the database. The same queries can also be found directly at the end of the [notebook](core_EDA.ipynb) using [`sqlalchemy`](https://www.sqlalchemy.org/).

# Notes

The datatables `personnel` and `professors` are in need of some further data cleaning because the codes employed in the datatables contain some additional complexities and cleaning them has not been a priority for now.

This dataset was initially created in the course of an [Ironhack](https://www.ironhack.com/) bootcamp on Data Science and Machine Learning.



# License

Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
