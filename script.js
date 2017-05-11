"use strict";

const BLOCK_SIZE = 50;

document.addEventListener('DOMContentLoaded', main);

function main() {
  const form = document.querySelector('form[name="display"]');

  form.addEventListener('submit', (event) => {
    event.preventDefault();

    const json = JSON.parse(document.getElementById('maze-json').value);
    const start = document.getElementById('start').value;
    const end = document.getElementById('end').value;
    const maze = document.getElementById('maze');

    displayMaze(maze, json, start, end);
  });
};

function displayMaze(maze, json, start, end) {
  let blocks = [];

  maze.innerHTML = null;

  for (let coordinates in json) {
    let [x, y] = coordinates.split(',');
    let directions = json[coordinates].map(direction => `block-${direction}`);

    blocks[coordinates] = createMazeBlock(x, y, directions);
    maze.appendChild(blocks[coordinates]);
  }

  addFlag(blocks[start], 'start');
  addFlag(blocks[end], 'end');
};

function createMazeBlock(x, y, directions) {
  let block = document.createElement('div');
  let left = parseInt(x, 10) * BLOCK_SIZE;
  let top = parseInt(y, 10) * BLOCK_SIZE;

  block.classList.add('block');
  directions.map(direction => block.classList.add(direction));
  block.style = `left: ${left}px; top: ${top}px;`;

  return block;
};

function addFlag(block, flagType) {
  const template = document.getElementById(`flag-${flagType}`);
  let flag = document.importNode(template.content, true);

  block.appendChild(flag);
};

