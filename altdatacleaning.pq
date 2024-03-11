let
    // Load CSV data
    Source = Csv.Document(File.Contents("C:\Users\dAgDaN\Desktop\Excel Projects\Market Basket Analysis\Titanic-Dataset.csv"), [Delimiter=",", Columns=12, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    
    // Promote headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    
    // Change data types
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {
        {"PassengerId", Int64.Type}, {"Survived", Int64.Type}, {"Pclass", Int64.Type},
        {"Name", type text}, {"Sex", type text}, {"Age", type number},
        {"SibSp", Int64.Type}, {"Parch", Int64.Type}, {"Ticket", type text},
        {"Fare", type number}, {"Cabin", type text}, {"Embarked", type text}
    }),

    // Transform Pclass values
    TransformPclass = Table.TransformColumns(#"Changed Type", {
        {"Pclass", each if _ = 1 then "First Class" else if _ = 2 then "Second Class" else "Third Class", type text}
    }),

    // Replace non-printable characters
    ReplaceNonPrintable = Table.ReplaceValue(TransformPclass, "#(00A0)", "", Replacer.ReplaceValue, {"Pclass"}),

    // Remove rows with null Age values
    RemoveNull = Table.SelectRows(ReplaceNonPrintable, each [Age] <> null),

    // Define column transformations
    ColumnTransformations = {
        {"First Class", each if [Pclass] = "First Class" then 1 else 0},
        {"Second Class", each if [Pclass] = "Second Class" then 1 else 0},
        {"Third Class", each if [Pclass] = "Third Class" then 1 else 0},
        {"Female", each if [Sex] = "female" then 1 else 0},
        {"Male", each if [Sex] = "male" then 1 else 0},
        {"Children", each if [Age] <= 18 then 1 else 0},
        {"Adult", each if [Age] > 18 and [Age] <= 50 then 1 else 0},
        {"Old", each if [Age] > 50 then 1 else 0}
    },

    // Apply column transformations
    TransformedColumns = List.Accumulate(ColumnTransformations, RemoveNull, (table, transformation) => Table.AddColumn(table, transformation{0}, transformation{1})),

    // Select final columns
    FinalData = Table.SelectColumns(TransformedColumns, {"PassengerId", "First Class", "Second Class", "Third Class", "Female", "Male", "Children", "Adult", "Old", "Survived"})
in
    FinalData
