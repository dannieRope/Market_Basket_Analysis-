let
    Source = Csv.Document(File.Contents("C:\Users\dAgDaN\Desktop\Excel Projects\Market Basket Analysis\Titanic-Dataset.csv"),[Delimiter=",", Columns=12, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"PassengerId", Int64.Type}, {"Survived", Int64.Type}, {"Pclass", Int64.Type}, {"Name", type text}, {"Sex", type text}, {"Age", type number}, {"SibSp", Int64.Type}, {"Parch", Int64.Type}, {"Ticket", type text}, {"Fare", type number}, {"Cabin", type text}, {"Embarked", type text}}),
    ChooseColumn = #"Changed Type"[[PassengerId],[Pclass],[Sex],[Age],[Survived]],
    TransformPclass = Table.TransformColumns(ChooseColumn,{{"Pclass", each if _ = 1 then "First Class" else if _ = 2 then "Second Class" else "Third Class", type text}}),
    ReplaceNonPrintable = Table.ReplaceValue(TransformPclass,"#(00A0)","",Replacer.ReplaceValue,{"Pclass"}),
    RemoveNull = Table.SelectRows(ReplaceNonPrintable, each [Age] <> null),
    FirstClass = Table.AddColumn(RemoveNull, "First Class", each  if [Pclass] = "First Class" then 1 else 0),
    SecondClass = Table.AddColumn(FirstClass, "Second Class", each  if [Pclass] = "Second Class" then 1 else 0),
    ThirdClass = Table.AddColumn(SecondClass, "Third Class", each  if [Pclass] = "Third Class" then 1 else 0),
    Female = Table.AddColumn(ThirdClass, "Female", each  if [Sex] = "female" then 1 else 0),
    Male = Table.AddColumn(Female, "Male", each  if [Sex] = "male" then 1 else 0),
    Children = Table.AddColumn(Male,"Children", each if [Age] <= 18 then 1 else 0),
    Adult = Table.AddColumn(Children,"Adult", each if [Age] > 18 and [Age]<= 50 then 1 else 0),
    Old = Table.AddColumn(Adult,"Old", each if [Age] > 50 then 1 else 0),
    FinalData = Old[[PassengerId],[First Class],[Second Class],[Third Class],[Female],[Male],[Children],[Adult],[Old],[Survived]]
in
    FinalData
