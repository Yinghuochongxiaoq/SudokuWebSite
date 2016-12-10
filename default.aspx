<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default.aspx.cs" Inherits="_Default" EnableViewState="false" Debug="false" %>

<!DOCTYPE html>
<html>
<head>
    <title>The Neat Sudoku Solver</title>

    <script type="text/javascript">
        window.onload = buildTable;
        var PuzzleIndex = '<% = Request["PuzzleList"] %>';
        var PuzzleData = '<% = Request["PuzzleData"] %>';
        //初始化5个题目
        var puzzle = [];
        puzzle[0] = "000000000000495000506000104001802600000000000005709200204000805000687000080504030";
        puzzle[1] = "530070000600195000098000060800060003400803001700020006060000280000419005000080079";
        puzzle[2] = "070000090200800000000000600000005000000000700007020000700400000000200050000700000";
        puzzle[3] = "500000000001000000030005000000600000000010000300000000000000300000300070050000000";
        puzzle[4] = "000002030000700000000000006000006008200000000000400090100000000030500000009000060";
        puzzle[5] = "021000000000700000000080050002000000084000000005000000070000009300000020800000000";

        function buildTable() {
            var griddiv = document.getElementById("grid");
            griddiv.innerHTML = "<table id='gridTable' ></table>";

            var tbody = document.getElementById("gridTable");

            for (var i = 0; i < 9; i++) {
                var row = document.createElement("tr");
                var strRow = "";
                for (var j = 0; j < 9; j++) {
                    strRow += "<td><input type='number' min='1' max='9' /></td>";
                }
                row.innerHTML = strRow;
                tbody.appendChild(row);
            }

            loadPuzzle();

            document.getElementById("PuzzleList").selectedIndex = PuzzleIndex;
            var outData = document.getElementById("outData");
            if (outData.innerHTML.length == 81) {
                var cells = document.getElementsByTagName("input");
                for (var i = 0; i < 81; i++) {
                    cells[i].value = outData.innerHTML.charAt(i);
                }
                var msg = "<b>Success</b>. ";
                var outCost = document.getElementById("outCost");
                var Cost = outCost.innerHTML;
                if (Cost != "0")
                    msg = "<b>No Solution</b>. The above is an approximate solution with viloation measure = " + Cost;

                showMessage(msg);
            }
        }

        function submitData() {
            var puzdata = "";
            //拼接输入请求参数
            var cells = document.getElementsByTagName("input");
            for (var i = 0; i < 81; i++) {
                var val = parseInt(cells[i].value);
                if (isNaN(val)) {
                    puzdata += "0";
                    continue;
                }
                if ((val < 1) || (val > 9)) {
                    showMessage("Invalid input");
                    return;
                }
                puzdata += val;
            }

            document.getElementById("PuzzleData").value = puzdata;
            document.forms[0].submit();
            var msg = "Wait ... it may take about 15 seconds to find a solution.";
            showMessage(msg);
        }

        function submitDataExt() {
            document.getElementById("PuzzleData").value = PuzzleData;
            document.forms[0].submit();
            var msg = "Wait ... it may take about 15 seconds to find a solution.";
            showMessage(msg);
        }

        function randomPuzzle() {
            var puzdata = new Array(81);
            var i;
            for (i = 0; i < 81; i++) {
                puzdata[i] = 0;
            }

            var Max = Math.floor(Math.random() * 10) + 15;
            var count = 0;
            var row, col, val;
            while (count < Max) {
                row = Math.floor(Math.random() * 9);
                col = Math.floor(Math.random() * 9);

                if (puzdata[col + 9 * row] != 0) continue;

                var values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
                for (i = 0; i < 9; i++) {
                    val = puzdata[i + 9 * row];
                    values[val] = 0;
                }

                for (i = 0; i < 9; i++) {
                    val = puzdata[col + i * 9];
                    values[val] = 0;
                }

                var fromRow = 6;
                if (row < 3) fromRow = 0;
                else if (row < 6) fromRow = 3;

                var fromCol = 6;
                if (col < 3) fromCol = 0;
                else if (col < 6) fromCol = 3;

                for (i = fromRow; i < fromRow + 3; i++)
                    for (var j = fromCol; j < fromCol + 3; j++) {
                        val = puzdata[j + i * 9];
                        values[val] = 0;
                    }
                var pos;
                while (true) {
                    pos = Math.floor(Math.random() * 9) + 1;
                    if (values[pos] != 0) break;
                }

                puzdata[col + 9 * row] = values[pos];
                count++;
            }

            PuzzleData = puzdata.join("");
            var outData = document.getElementById("outData");
            outData.innerHTML = PuzzleData;
            loadPuzzle();
        }

        function loadPuzzle(list) {
            var outMessage = document.getElementById("outMessage");
            outMessage.innerHTML = "";
            var InpData = PuzzleData;
            if (PuzzleData == "") InpData = puzzle[0];

            if (list) {
                PuzzleIndex = list.options[list.selectedIndex].value;
                InpData = puzzle[PuzzleIndex];
            }

            var cells = document.getElementsByTagName("input");
            for (var i = 0; i < 81; i++) {
                if (InpData[i] != '0') {
                    cells[i].value = InpData[i];
                    cells[i].parentNode.className = "fixed";
                }
                else {
                    cells[i].value = "";
                    cells[i].parentNode.className = "";
                }
            }
        }

        function showMessage(msg) {
            var outMessage = document.getElementById("outMessage");
            outMessage.innerHTML = msg;
        }

    </script>

    <style type="text/css">
        body {
            padding: 0;
            margin: 0;
            padding-left: 10px;
            font-size: 1.1em;
        }

        h2 {
            text-align: left;
            font-size: 20pt;
            font-style: italic;
            font-family: Tahoma;
            color: white;
            padding: 16px;
            padding-left: 40px;
            margin: 0;
            border-bottom: 1px solid black;
            margin-left: -12px;
        }

        h2 {
            background-image: -o-linear-gradient(right, #292829 0%, #F7F7F7 100%);
            background-image: -moz-linear-gradient(right, #292829 0%, #F7F7F7 100%);
            background-image: -webkit-linear-gradient(right, #292829 0%, #F7F7F7 100%);
            background-image: -ms-linear-gradient(right, #292829 0%, #F7F7F7 100%);
            background-image: linear-gradient(to right, #292829 0%, #F7F7F7 100%);
        }

        div#grid table {
            border-collapse: collapse;
            border-spacing: 0;
            padding: 0;
            margin: 30px 10px 26px 40px;
            table-layout: fixed;
        }

            div#grid table td {
                border: 1px solid gray;
                margin: 0;
                padding: 0;
                width: 50px;
                height: 50px;
            }

                div#grid table td.fixed {
                    color: red;
                }

                div#grid table td:nth-child(3n+3) {
                    border-right: 2px solid black;
                }

            div#grid table tr:nth-child(3n+3) {
                border-bottom: 2px solid black;
            }

            div#grid table tr:first-child {
                border-top: 2px solid black;
            }

            div#grid table tr td:first-child {
                border-left: 2px solid black;
            }

        input[type=text],input[type=number] {
            width: 90%;
            height: 48px;
            padding: 2px;
            margin: 0;
            border: 0;
            font-size: 16pt;
            text-align: center;
            color: inherit;
        }

        input[type=button] {
            margin-left: 18px;
            padding: 2px 6px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h2>The Neat Sudoku Solver</h2>
    <div id="grid"></div>
    <form id="form1" method="post" action="">
        <div>
            <input type="hidden" id="PuzzleData" name="PuzzleData" />

            <label>
                <i>Select puzzle</i>&nbsp;
      <select id="PuzzleList" onchange="loadPuzzle(this)" name="PuzzleList">
          <option value="0">Puzzle 1</option>
          <option value="1">Puzzle 2</option>
          <option value="2">Puzzle 3</option>
          <option value="3">Puzzle 4</option>
          <option value="4">Puzzle 5</option>
          <option value="5">Hard puzzle</option>
      </select>
            </label>
            <input type="button" onclick="randomPuzzle()" value="Ranom Puzzle" />
            <input type="button" onclick="submitData()" value="Solve It" />
            <input type="button" onclick="submitDataExt()" value="Another Solution" />
        </div>
    </form>
    <div id="outData" runat="server" style="display: none"></div>
    <div id="outCost" runat="server" style="display: none"></div>
    <div id="outMessage" style="color: red; font-style: italic; margin-top: 6px;"></div>
</body>
</html>
