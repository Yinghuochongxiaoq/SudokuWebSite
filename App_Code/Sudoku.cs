using System;

public class Sudoku
{
    internal static int[,] PosRow = new int[27, 9];
    internal static int[,] PosCol = new int[27, 9];
    internal int[] FixedCell = new int[81];

    readonly Random rand = new Random((int)DateTime.Now.Ticks);

    public int SolveIt(string FC, int AllotedTime, out int[,] grid)
    {
        SetRowColPos();

        PuzzleFromString(FC, this.FixedCell);

        Solution s1 = new Solution(this.FixedCell, this.rand);
        s1.SetInitialSolution();
        Solution BestSolution = ProgressiveSearch(s1, AllotedTime);
        grid = BestSolution.grid;
        return (int)BestSolution.Cost;
    }

    static void SetRowColPos()
    {
        // set PosRow/PosCol to correspond to 9 row-constraints, 9 col-constraints and 9 box-constrains
        // fill the row,col positions for the 9 rows (i changes over rows)
        for (int i = 0; i < 9; i++)
            for (int j = 0; j < 9; j++)
            {
                PosRow[i, j] = i;
                PosCol[i, j] = j;
            }

        // fill the row,col positions for the 9 columns (i changes over columns)
        for (int i = 9; i < 18; i++)
            for (int j = 0; j < 9; j++)
            {
                PosRow[i, j] = j;
                PosCol[i, j] = (i - 9);
            }

        // fill the row,col positions for the top left square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[18, j] = j / 3;
            PosCol[18, j] = j % 3;
        }

        // fill the row,col positions for the middle top square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[19, j] = j / 3;
            PosCol[19, j] = 3 + j % 3;
        }

        // fill the row,col positions for the top right square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[20, j] = j / 3;
            PosCol[20, j] = 6 + j % 3;
        }

        // fill the row,col positions for the middle left square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[21, j] = 3 + (j / 3);
            PosCol[21, j] = j % 3;
        }

        // fill the row,col positions for the middle center square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[22, j] = 3 + (j / 3);
            PosCol[22, j] = 3 + j % 3;
        }

        // fill the row,col positions for the middle right  square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[23, j] = 3 + (j / 3);
            PosCol[23, j] = 6 + j % 3;
        }

        // fill the row,col positions for the bottom left square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[24, j] = 6 + (j / 3);
            PosCol[24, j] = j % 3;
        }

        // fill the row,col positions for the bottom center square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[25, j] = 6 + (j / 3);
            PosCol[25, j] = 3 + j % 3;
        }

        // fill the row,col positions for the bottom right square 
        for (int j = 0; j < 9; j++)
        {
            PosRow[26, j] = 6 + (j / 3);
            PosCol[26, j] = 6 + j % 3;
        }
    }


    static Solution ProgressiveSearch(Solution node, int AllotedTime)
    {
        DateTime StartTime = DateTime.Now;
        PriorityQueue Queue = new PriorityQueue();
        // Set ProgressiveSearch parameters 
        Queue.MaxSize = 40; // Queue MaxSize
        int NBSIZE = 120;  // Neighborhood size

        float BestCost = node.Cost;
        Solution BestSolution = node;

        Queue.Enqueue(node, -node.Cost);

        while (Queue.Count > 0)
        {
            if (BestCost == 0) break;

            node = (Solution)Queue.RandomItem();
            int nbcount = 0;
            while (nbcount <= NBSIZE)
            {
                if ((DateTime.Now - StartTime).TotalSeconds > AllotedTime) { return BestSolution; }

                Solution node1 = node.NewSolution();
                Queue.Enqueue(node1, -node1.Cost);
                nbcount++;

                if (node1.Cost < BestCost)
                {
                    BestCost = node1.Cost;
                    BestSolution = node1;
                    node = node1; nbcount = 0;
                    if (BestCost == 0) break;
                }

                else if (node1.Cost <= BestCost + 3) // Important: progressive search here
                { node = node1; nbcount = 0; }
            }
        }
        return BestSolution;
    }


    static void PuzzleFromString(string InpStr, int[] FixedCell)
    {
        for (int i = 0; i < 81; i++)
        {
            FixedCell[i] = 0;
            if (InpStr[i] != '0') FixedCell[i] = InpStr[i] - '0';
        }
    }
}

class Solution
{
    // static Random rand = new Random(); // This causes a problem for concurrent web requests
    // Instead, the random object is a member of the Sudoku instance and passed to the Solution() constructor
    Random rand;
    internal int[,] grid = new int[9, 9];
    internal float Cost; // The PQUEUE class uses float for priority values
    int[] FixedCell;
    internal Solution(int[] FixedCell, Random rand) { this.FixedCell = FixedCell; this.rand = rand; }

    internal void SetInitialSolution() // set initial grid as 1,2 .. 9 in each row
    {
        for (int i = 0; i < 9; i++)
            for (int j = 0; j < 9; j++)
            { this.grid[i, j] = j + 1; }

        this.Cost = this.ComputeMeasure();
    }

    int ComputeMeasure()
    {
        int[] perm = new int[9];
        int sum = 0;

        for (int k = 0; k < 27; k++)
        {
            for (int i = 0; i < 9; i++) perm[i] = 0;
            for (int i = 0; i < 9; i++) perm[this.grid[Sudoku.PosRow[k, i], Sudoku.PosCol[k, i]] - 1] += 1;
            for (int i = 0; i < 9; i++)
            {
                if (perm[i] == 0) sum++; // digit i is missing
                else if (perm[i] > 1) sum += perm[i] - 1; // digit i occurs more than once
            }
        }

        // check fixed cells; have a large weight (per cell) here than above
        for (int i = 0; i < 81; i++)
            if (this.FixedCell[i] != 0)
                if (this.grid[i / 9, i % 9] != this.FixedCell[i]) sum = sum + 8;

        return sum;
    }


    Solution CopySolution()
    {
        Solution s = new Solution(this.FixedCell, this.rand);
        Array.Copy(this.grid, s.grid, this.grid.Length);
        // s.Cost = Cost;
        return s;
    }

    internal Solution NewSolution()
    {
        Solution s1 = this.CopySolution();

        int i = this.rand.Next(81);
        int j = i;
        while (i == j) { j = this.rand.Next(81); }

        int t = s1.grid[i / 9, i % 9];
        s1.grid[i / 9, i % 9] = s1.grid[j / 9, j % 9];
        s1.grid[j / 9, j % 9] = t;

        s1.Cost = s1.ComputeMeasure();
        return s1;
    }
}