const _ = require('lodash');


const maze = {};
const MAX_SIZE = 10;


function random(size) {
  return Math.floor(Math.random() * size);
}

const initialSquare = {
  x: random(MAX_SIZE),
  y: random(MAX_SIZE)
};
console.log('initialSquare=', initialSquare);

function squareId(square) {
  return square.x + ',' + square.y;
}

function computeNeighbors(square) {
  const { x, y } = square;
  const neighbors = [{
    x: x - 1,
    y
  }, {
    x: x + 1,
    y
  }, {
    x,
    y: y - 1
  }, {
    x,
    y: y + 1
  }];
  return neighbors.filter(sq => sq.x >= 0 && sq.x < MAX_SIZE && sq.y >= 0 && sq.y < MAX_SIZE);
}


let neighborsToVisit = computeNeighbors(initialSquare);
const squareVisited = [initialSquare];


function sameSquare(a, b) {
  return squareId(a) === squareId(b);
}

function step() {
  const currentSquare = neighborsToVisit.splice(random(neighborsToVisit.length), 1)[0];
  const currentNeighbors = computeNeighbors(currentSquare);

  const [visited, newNeighbors] = _.partition(currentNeighbors, n => {
    return squareVisited.map(squareId).includes(squareId(n));
  });
  neighborsToVisit = _.uniqBy(neighborsToVisit.concat(newNeighbors), squareId);

  const target = visited[random(visited.length)];
  openWall(currentSquare, target);
  openWall(target, currentSquare);
  squareVisited.push(currentSquare);
}

while(neighborsToVisit.length > 0) {
  step();
}

console.log('\n================');
// console.log('squareVisited', squareVisited);
console.log('maze\n', JSON.stringify(maze));

function openWall(squareSource, squareTarget) {
  const wall = findOpenWall(squareSource, squareTarget);
  const id = squareId(squareSource);
  maze[id] = (maze[id] || []).concat([wall]);
}

function findOpenWall(squareSource, squareTarget) {
  if (squareTarget.x > squareSource.x) {
    return 'E';
  }
  if (squareTarget.x < squareSource.x) {
    return 'W';
  }
  if (squareTarget.y > squareSource.y) {
    return 'S';
  }
  if (squareTarget.y < squareSource.y) {
    return 'N';
  }
}
