pragma circom 2.0.0;

template NonEqual(){
    signal input in0;
    signal input in1;
    signal inv;
    inv <-- 1/ (in0 - in1);
    inv*(in0 - in1) === 1;
}

template Distinct(n) {
    signal input in[n];
    component nonEqual[n][n];
    for(var i = 0; i < n; i++){
        for(var j = 0; j < i; j++){
            nonEqual[i][j] = NonEqual();
            nonEqual[i][j].in0 <== in[i];
            nonEqual[i][j].in1 <== in[j];
        }
    }
}

// Enforce that 0 <= in < 16
template Bits4(){
    signal input in;
    signal bits[4];
    var bitsum = 0;
    for (var i = 0; i < 4; i++) {
        bits[i] <-- (in >> i) & 1;
        bits[i] * (bits[i] - 1) === 0;
        bitsum = bitsum + 2 ** i * bits[i];
    }
    bitsum === in;
}

// Enforce that 1 <= in <= 9
template OneToNine() {
    signal input in;
    component lowerBound = Bits4();
    component upperBound = Bits4();
    lowerBound.in <== in - 1;
    upperBound.in <== in + 6;
}

template Sudoku(n) {
    // solution is a 2D array: indices are (row_i, col_i)
    signal input solution[n][n];
    // puzzle is the same, but a zero indicates a blank
    signal input puzzle[n][n];

    component distinctCol[n];
    component distinctRow[n];
    component distinctSq[n];
    component inRange[n][n];


    // check validility
    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            inRange[row_i][col_i] = OneToNine();
            inRange[row_i][col_i].in <== solution[row_i][col_i];
        }
    }

    // check if matching the puzzle input
    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            // we could make this a component
            puzzle[row_i][col_i] * (puzzle[row_i][col_i] - solution[row_i][col_i]) === 0;
        }
    }

    // check for columns
    for (var col_i = 0; col_i < n; col_i++) {
        distinctCol[col_i] = Distinct(n);
        for (var row_i = 0; row_i < n; row_i++) {
            distinctCol[col_i].in[row_i] <== solution[row_i][col_i];
        }
    }

    // check for rows
    for (var row_i = 0; row_i < n; row_i++) {
        distinctRow[row_i] = Distinct(n);
        for (var col_i = 0; col_i < n; col_i++) {
            distinctRow[row_i].in[col_i] <== solution[row_i][col_i];
        }
    }

    // check for squares
    // | 0 | 1 | 2 |
    // | 3 | 4 | 5 |
    // | 6 | 7 | 8 | 
    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            var index = ((row_i \ 3) * 3) + col_i \ 3;
            if ((row_i % 3 == 0) && (col_i % 3 == 0)) {
                distinctSq[index] = Distinct(n);
            }
            var position = ((row_i % 3) * 3) + (col_i % 3);
            distinctSq[index].in[position] <== solution[row_i][col_i];
        }
    }
}

component main {public[puzzle]} = Sudoku(9);

