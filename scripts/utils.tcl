# Based on code from ComPair and BurstCube projects, originally ported from NASA GSFC Code 500 SDL. 

# this is a collection of useful project utilities

# implement touch - opens a file updating the time stamp,
# creating it if it does not exist
proc touch {f} {
   set FILEIN [open $f w]
   close $FILEIN
}