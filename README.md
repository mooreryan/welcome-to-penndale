# Welcome to Penndale App Source Code

Source code for the Welcome to Penndale app.

## Generate the LetterDayCalendar data

- Get the letter day calendar data from the Google Doc.
- Run the `./scripts/parse_letter_day_calendar.rb` script on the `letter_day_calendar.tsv` data from the Google doc.
- Take the generated Elm code and put it in the `./src/LetterDayCalendar.elm` file as the `letterDayCalendar`.

Something like this:

```
$ ruby scripts/parse_letter_day_calendar.rb letter_day_calendar.tsv > letter_day_calendar.txt
```

## To do

- [ ] Manage SVGs with WebPack rather than sticking them in the `public` folder.
