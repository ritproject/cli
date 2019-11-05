# About this folder

The `rit.sh` is a placeholder for the unix script created after `mix release`.

Instead of managing application, this script calls the function
`RitCLI.parse_and_exec/1` which converts the input to a list of strings before
running `RitCLI.main/1` function.
