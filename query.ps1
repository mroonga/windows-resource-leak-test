# Include
[reflection.Assembly]::LoadFrom("C:\Users\Administrator\windows-resource-leak-test\MySql.Data.dll")
# 検索文字列ファイル
$searchStrFile="C:\Users\Administrator\windows-resource-leak-test\searchStr.txt"
# 接続情報
$MySQLConnectionStr = "server=localhost;port=3306;uid=root;database=mroonga_test;password=zzzzzzzz;Pooling=False"
# 接続情報：パスワードを設定している場合
# $MySQLConnectionStr = "server=localhost;port=3306;uid=root;database=mroonga_test;password=zzzzzzzz;Pooling=False"
#log
$qcLog="C:\Users\Administrator\windows-resource-leak-test\qcLog_"+(Get-Date).ToString("yyyyMMdd")+".txt"
 ##########
# function #
 ##########
#簡易ログ出力
function writeQcLog($logLevel, $message){
    $logStr="["+(Get-Date).ToString("yyyy/MM/dd/ HH:mm:ss")+"] (@logLevel) @message"
    $logStr=$logStr -replace "@logLevel","$logLevel"
    $logStr=$logStr -replace "@message","$message"
    Write-Output $logStr | Add-Content $qcLog -Encoding Default
}

$searchStrArray = (Get-Content -Encoding UTF8 $searchStrFile) -as [string[]]

## 本文検索処理
$sql1=" SELECT dsp.MUNICIPALITY_ID, null AS DOCUMENT_ID, null AS INDEX_ID, null AS BODY_ID, null AS SORT_NO, dsp.FILE_PATH, dsp.FILE_TYPE, dsp.URL, CASE WHEN dsp.PAGE_TXT = '' THEN dsp.SEL_PAGE_TXT ELSE dsp.PAGE_TXT END SEL_PAGE_TXT, null AS titleScore, null AS txtScore, null AS indexLevelNmScore"
$sql1+=" , MATCH (dsp.SEL_PAGE_TXT) AGAINST('*W1:1 +@searchStr' IN BOOLEAN MODE) AS scoreStaPa"
$sql1+=" FROM DAT_STATIC_PAGE2 AS dsp "
$sql1+=" WHERE MATCH(dsp.SEL_PAGE_TXT) against('@searchStr' IN BOOLEAN MODE)"
$sql1+=" order by (titleScore + txtScore + indexLevelNmScore) DESC, MUNICIPALITY_ID ASC, SORT_NO ASC, scoreStaPa DESC, FILE_TYPE ASC, FILE_PATH ASC; "

for ($i = 0; $i -lt 10000000; $i++) {
    
    $searchStr = Get-Random $searchStrArray
    $searchStr += Get-Random $searchStrArray
    $searchStr += Get-Random $searchStrArray
    
    try{
        $query= $sql1 -replace "@searchStr","$searchStr"
        
        # クエリ実行
        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($MySQLConnectionStr)
        $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
        $da = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($cmd)
        $ds = New-Object System.Data.DataSet
        [void]$da.Fill($ds)
    }catch [Exception]{
        Write-Host $error
    }finally{
        $connection.Close()
    }

    #Get-Process mysqld
#    $process = Get-Process mysqld

    #Write-Host $searchStr $process.WorkingSet64
    Write-Host $searchStr $i
    #writeQcLog $searchStr $i
}
