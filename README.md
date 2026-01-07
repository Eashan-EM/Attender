# Introduction

This app was made in an effort to make attendance marking easier

# What are Rules?

For creating the Roll Numbers, a rule based syntax is used which makes it easier to generate the numbers

As of v1.0, the following rules do work
The only rule currently supported are lists and ranges which use `[]` to parse

```rules
[0..10]  -> [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]  // Example of range
[00..15] -> [00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10] // Example of range with minimum width charater at left, the '0' is padded when length < 2
```
Rules with external string
```rules
24CSE10[01, 02, 03] -> [24CSE1001, 24CSE1002, 24CSE1003]  // The string outside [] remains unchanged
24CSE10[01..03]     -> [24CSE1001, 24CSE1002, 24CSE1003]
24CSE[10, 11][00..03] -> [24CSE1000, 24CSE1001, 24CSE1002, 24CSE1003, 24CSE1100, 24CSE1101, 24CSE1102, 24CSE1103]
```

## Output Rules
While printing formatted output, special variables are available

```
Absentees on [Date.today]
[section0.Absentees]

Backlog Presentees on [Date.today]
[section1.Presentees]
```
As it can be seen `[]` is used to mark the parsable code

`[Date.today]` as its name says, returns the current date in `dd/mm/yyyy` format

To use the `sectionX`, where x = 0,1..., sections should be created using `Add Section`. The section number corresponds to the section title

Each section variable has a `.Presentees` and `.Absentees`, which gives the required cards