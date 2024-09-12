% dataset(DirectoryName)
% this is where the image dataset is located
dataset('C:\\users\\jonat\\OneDrive\\Desktop\\Project 4\\imageDataset2_15_20\\').
projectDir('C:\\users\\jonat\\OneDrive\\Desktop\\Project 4\\').

% directory_textfiles(DirectoryName, ListOfTextfiles)
% produces the list of text files in a directory
directory_textfiles(D,Textfiles):- directory_files(D,Files), include(isTextFile, Files, Textfiles).
isTextFile(Filename):-string_concat(_,'.txt',Filename).

% read_hist_file(Filename,ListOfNumbers)
% reads a histogram file and produces a list of numbers (bin values)
read_hist_file(Filename,Numbers):- open(Filename,read,Stream),read_line_to_string(Stream,_),
                                   read_line_to_string(Stream,String), close(Stream),
								   atomic_list_concat(List, ' ', String),atoms_numbers(List,Numbers).
								   
% similarity_search(QueryFile,SimilarImageList)
% returns the list of images similar to the query image
% similar images are specified as (ImageName, SimilarityScore)
% predicat dataset/1 provides the location of the image set
similarity_search(QueryFile,SimilarList) :- dataset(D), directory_textfiles(D,TxtFiles),
                                            projectDir(PD),
                                            atom_concat(PD, QueryFile, Query),
                                            similarity_search(Query,D,TxtFiles,SimilarList).
											
% similarity_search(QueryFile, DatasetDirectory, HistoFileList, SimilarImageList)
similarity_search(QueryFile,DatasetDirectory, DatasetFiles,Best):-
                                            computeHistso(QueryFile, QueryHisto),
                                            compare_histograms(QueryHisto, DatasetDirectory, DatasetFiles, Scores), 
                                            sort(2,@>,Scores,Sorted),take(Sorted,5,Best).

% compare_histograms(QueryHisto,DatasetDirectory,DatasetFiles,Scores)
% compares a query histogram with a list of histogram files
compare_histograms(_,_,[],[]).
compare_histograms(QueryHisto, DatasetDirectory, [DH | DT], [(DH,Score)|Scores1]):-
    atom_concat(DatasetDirectory,DH, Dfile),
    computeHistso(Dfile, DHisto),
    histogram_intersection(QueryHisto,DHisto,Score),
    compare_histograms(QueryHisto,DatasetDirectory,DT,Scores1).
    

% histogram_intersection(Histogram1, Histogram2, Score)
% compute the intersection similarity score between two histograms
% Score is between 0.0 and 1.0 (1.0 for identical histograms)
histogram_intersection([],[],0).
histogram_intersection([H1|T1],[H2|T2], S):-
    histogram_intersection(T1,T2,S1),
    S is min(H1,H2) + S1.
    
% take(List,K,KList)
% extracts the K first items in a list
take(Src,N,L) :- findall(E, (nth1(I,Src,E), I =< N), L).
% atoms_numbers(ListOfAtoms,ListOfNumbers)
% converts a list of atoms into a list of numbers
atoms_numbers([],[]).
atoms_numbers([X|L],[Y|T]):- atom_number(X,Y), atoms_numbers(L,T).
atoms_numbers([X|L],T):- \+atom_number(X,_), atoms_numbers(L,T).

%sum of all elements in a list
sum([],0).
sum([H|T],S):- 
    sum(T,S1),
    S is S1 + H.

%Normalize Histo
normalize([],_,[]).
normalize([H|T],Sum,[H1|T1]):-
    H1 is H/Sum,
    normalize(T,Sum,T1).

%Reads the file, returns its normalized histogram
computeHistso(FileName, R):-
    read_hist_file(FileName, Histo),
    sum(Histo, Sum),
    normalize(Histo, Sum, R).
