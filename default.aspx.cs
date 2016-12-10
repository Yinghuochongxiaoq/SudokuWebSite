using System;
using System.Globalization;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["PuzzleData"] == null) return;
        Server.ScriptTimeout = 30;
        var mySudoku = new Sudoku();
        int[,] grid;
        const int AllotedTime = 20;
        int Cost = mySudoku.SolveIt(Request["PuzzleData"], AllotedTime, out grid);

        outData.InnerText = GridToString(grid);
        outCost.InnerText = Cost.ToString(CultureInfo.InvariantCulture);
    }

    /// <summary>
    /// 生成解决的串
    /// </summary>
    /// <param name="grid"></param>
    /// <returns></returns>
    string GridToString(int[,] grid)
    {
        string str = "";
        for (int i = 0; i < 9; i++)
        {
            for (int j = 0; j < 9; j++)
            {
                str += grid[i, j];
            }
        }
        return str;
    }
}
