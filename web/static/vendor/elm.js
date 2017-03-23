
(function() {
'use strict';

function F2(fun)
{
  function wrapper(a) { return function(b) { return fun(a,b); }; }
  wrapper.arity = 2;
  wrapper.func = fun;
  return wrapper;
}

function F3(fun)
{
  function wrapper(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  }
  wrapper.arity = 3;
  wrapper.func = fun;
  return wrapper;
}

function F4(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  }
  wrapper.arity = 4;
  wrapper.func = fun;
  return wrapper;
}

function F5(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  }
  wrapper.arity = 5;
  wrapper.func = fun;
  return wrapper;
}

function F6(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  }
  wrapper.arity = 6;
  wrapper.func = fun;
  return wrapper;
}

function F7(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  }
  wrapper.arity = 7;
  wrapper.func = fun;
  return wrapper;
}

function F8(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  }
  wrapper.arity = 8;
  wrapper.func = fun;
  return wrapper;
}

function F9(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  }
  wrapper.arity = 9;
  wrapper.func = fun;
  return wrapper;
}

function A2(fun, a, b)
{
  return fun.arity === 2
    ? fun.func(a, b)
    : fun(a)(b);
}
function A3(fun, a, b, c)
{
  return fun.arity === 3
    ? fun.func(a, b, c)
    : fun(a)(b)(c);
}
function A4(fun, a, b, c, d)
{
  return fun.arity === 4
    ? fun.func(a, b, c, d)
    : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e)
{
  return fun.arity === 5
    ? fun.func(a, b, c, d, e)
    : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f)
{
  return fun.arity === 6
    ? fun.func(a, b, c, d, e, f)
    : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g)
{
  return fun.arity === 7
    ? fun.func(a, b, c, d, e, f, g)
    : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h)
{
  return fun.arity === 8
    ? fun.func(a, b, c, d, e, f, g, h)
    : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i)
{
  return fun.arity === 9
    ? fun.func(a, b, c, d, e, f, g, h, i)
    : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

var _elm_lang$core$Native_Bitwise = function() {

return {
	and: F2(function and(a, b) { return a & b; }),
	or: F2(function or(a, b) { return a | b; }),
	xor: F2(function xor(a, b) { return a ^ b; }),
	complement: function complement(a) { return ~a; },
	shiftLeftBy: F2(function(offset, a) { return a << offset; }),
	shiftRightBy: F2(function(offset, a) { return a >> offset; }),
	shiftRightZfBy: F2(function(offset, a) { return a >>> offset; })
};

}();

var _elm_lang$core$Bitwise$shiftRightZfBy = _elm_lang$core$Native_Bitwise.shiftRightZfBy;
var _elm_lang$core$Bitwise$shiftRightBy = _elm_lang$core$Native_Bitwise.shiftRightBy;
var _elm_lang$core$Bitwise$shiftLeftBy = _elm_lang$core$Native_Bitwise.shiftLeftBy;
var _elm_lang$core$Bitwise$complement = _elm_lang$core$Native_Bitwise.complement;
var _elm_lang$core$Bitwise$xor = _elm_lang$core$Native_Bitwise.xor;
var _elm_lang$core$Bitwise$or = _elm_lang$core$Native_Bitwise.or;
var _elm_lang$core$Bitwise$and = _elm_lang$core$Native_Bitwise.and;

//import Native.List //

var _elm_lang$core$Native_Array = function() {

// A RRB-Tree has two distinct data types.
// Leaf -> "height"  is always 0
//         "table"   is an array of elements
// Node -> "height"  is always greater than 0
//         "table"   is an array of child nodes
//         "lengths" is an array of accumulated lengths of the child nodes

// M is the maximal table size. 32 seems fast. E is the allowed increase
// of search steps when concatting to find an index. Lower values will
// decrease balancing, but will increase search steps.
var M = 32;
var E = 2;

// An empty array.
var empty = {
	ctor: '_Array',
	height: 0,
	table: []
};


function get(i, array)
{
	if (i < 0 || i >= length(array))
	{
		throw new Error(
			'Index ' + i + ' is out of range. Check the length of ' +
			'your array first or use getMaybe or getWithDefault.');
	}
	return unsafeGet(i, array);
}


function unsafeGet(i, array)
{
	for (var x = array.height; x > 0; x--)
	{
		var slot = i >> (x * 5);
		while (array.lengths[slot] <= i)
		{
			slot++;
		}
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array = array.table[slot];
	}
	return array.table[i];
}


// Sets the value at the index i. Only the nodes leading to i will get
// copied and updated.
function set(i, item, array)
{
	if (i < 0 || length(array) <= i)
	{
		return array;
	}
	return unsafeSet(i, item, array);
}


function unsafeSet(i, item, array)
{
	array = nodeCopy(array);

	if (array.height === 0)
	{
		array.table[i] = item;
	}
	else
	{
		var slot = getSlot(i, array);
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array.table[slot] = unsafeSet(i, item, array.table[slot]);
	}
	return array;
}


function initialize(len, f)
{
	if (len <= 0)
	{
		return empty;
	}
	var h = Math.floor( Math.log(len) / Math.log(M) );
	return initialize_(f, h, 0, len);
}

function initialize_(f, h, from, to)
{
	if (h === 0)
	{
		var table = new Array((to - from) % (M + 1));
		for (var i = 0; i < table.length; i++)
		{
		  table[i] = f(from + i);
		}
		return {
			ctor: '_Array',
			height: 0,
			table: table
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = initialize_(f, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i-1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

function fromList(list)
{
	if (list.ctor === '[]')
	{
		return empty;
	}

	// Allocate M sized blocks (table) and write list elements to it.
	var table = new Array(M);
	var nodes = [];
	var i = 0;

	while (list.ctor !== '[]')
	{
		table[i] = list._0;
		list = list._1;
		i++;

		// table is full, so we can push a leaf containing it into the
		// next node.
		if (i === M)
		{
			var leaf = {
				ctor: '_Array',
				height: 0,
				table: table
			};
			fromListPush(leaf, nodes);
			table = new Array(M);
			i = 0;
		}
	}

	// Maybe there is something left on the table.
	if (i > 0)
	{
		var leaf = {
			ctor: '_Array',
			height: 0,
			table: table.splice(0, i)
		};
		fromListPush(leaf, nodes);
	}

	// Go through all of the nodes and eventually push them into higher nodes.
	for (var h = 0; h < nodes.length - 1; h++)
	{
		if (nodes[h].table.length > 0)
		{
			fromListPush(nodes[h], nodes);
		}
	}

	var head = nodes[nodes.length - 1];
	if (head.height > 0 && head.table.length === 1)
	{
		return head.table[0];
	}
	else
	{
		return head;
	}
}

// Push a node into a higher node as a child.
function fromListPush(toPush, nodes)
{
	var h = toPush.height;

	// Maybe the node on this height does not exist.
	if (nodes.length === h)
	{
		var node = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
		nodes.push(node);
	}

	nodes[h].table.push(toPush);
	var len = length(toPush);
	if (nodes[h].lengths.length > 0)
	{
		len += nodes[h].lengths[nodes[h].lengths.length - 1];
	}
	nodes[h].lengths.push(len);

	if (nodes[h].table.length === M)
	{
		fromListPush(nodes[h], nodes);
		nodes[h] = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
	}
}

// Pushes an item via push_ to the bottom right of a tree.
function push(item, a)
{
	var pushed = push_(item, a);
	if (pushed !== null)
	{
		return pushed;
	}

	var newTree = create(item, a.height);
	return siblise(a, newTree);
}

// Recursively tries to push an item to the bottom-right most
// tree possible. If there is no space left for the item,
// null will be returned.
function push_(item, a)
{
	// Handle resursion stop at leaf level.
	if (a.height === 0)
	{
		if (a.table.length < M)
		{
			var newA = {
				ctor: '_Array',
				height: 0,
				table: a.table.slice()
			};
			newA.table.push(item);
			return newA;
		}
		else
		{
		  return null;
		}
	}

	// Recursively push
	var pushed = push_(item, botRight(a));

	// There was space in the bottom right tree, so the slot will
	// be updated.
	if (pushed !== null)
	{
		var newA = nodeCopy(a);
		newA.table[newA.table.length - 1] = pushed;
		newA.lengths[newA.lengths.length - 1]++;
		return newA;
	}

	// When there was no space left, check if there is space left
	// for a new slot with a tree which contains only the item
	// at the bottom.
	if (a.table.length < M)
	{
		var newSlot = create(item, a.height - 1);
		var newA = nodeCopy(a);
		newA.table.push(newSlot);
		newA.lengths.push(newA.lengths[newA.lengths.length - 1] + length(newSlot));
		return newA;
	}
	else
	{
		return null;
	}
}

// Converts an array into a list of elements.
function toList(a)
{
	return toList_(_elm_lang$core$Native_List.Nil, a);
}

function toList_(list, a)
{
	for (var i = a.table.length - 1; i >= 0; i--)
	{
		list =
			a.height === 0
				? _elm_lang$core$Native_List.Cons(a.table[i], list)
				: toList_(list, a.table[i]);
	}
	return list;
}

// Maps a function over the elements of an array.
function map(f, a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? f(a.table[i])
				: map(f, a.table[i]);
	}
	return newA;
}

// Maps a function over the elements with their index as first argument.
function indexedMap(f, a)
{
	return indexedMap_(f, a, 0);
}

function indexedMap_(f, a, from)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? A2(f, from + i, a.table[i])
				: indexedMap_(f, a.table[i], i == 0 ? from : from + a.lengths[i - 1]);
	}
	return newA;
}

function foldl(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = foldl(f, b, a.table[i]);
		}
	}
	return b;
}

function foldr(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = a.table.length; i--; )
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = a.table.length; i--; )
		{
			b = foldr(f, b, a.table[i]);
		}
	}
	return b;
}

// TODO: currently, it slices the right, then the left. This can be
// optimized.
function slice(from, to, a)
{
	if (from < 0)
	{
		from += length(a);
	}
	if (to < 0)
	{
		to += length(a);
	}
	return sliceLeft(from, sliceRight(to, a));
}

function sliceRight(to, a)
{
	if (to === length(a))
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(0, to);
		return newA;
	}

	// Slice the right recursively.
	var right = getSlot(to, a);
	var sliced = sliceRight(to - (right > 0 ? a.lengths[right - 1] : 0), a.table[right]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (right === 0)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(0, right),
		lengths: a.lengths.slice(0, right)
	};
	if (sliced.table.length > 0)
	{
		newA.table[right] = sliced;
		newA.lengths[right] = length(sliced) + (right > 0 ? newA.lengths[right - 1] : 0);
	}
	return newA;
}

function sliceLeft(from, a)
{
	if (from === 0)
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(from, a.table.length + 1);
		return newA;
	}

	// Slice the left recursively.
	var left = getSlot(from, a);
	var sliced = sliceLeft(from - (left > 0 ? a.lengths[left - 1] : 0), a.table[left]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (left === a.table.length - 1)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(left, a.table.length + 1),
		lengths: new Array(a.table.length - left)
	};
	newA.table[0] = sliced;
	var len = 0;
	for (var i = 0; i < newA.table.length; i++)
	{
		len += length(newA.table[i]);
		newA.lengths[i] = len;
	}

	return newA;
}

// Appends two trees.
function append(a,b)
{
	if (a.table.length === 0)
	{
		return b;
	}
	if (b.table.length === 0)
	{
		return a;
	}

	var c = append_(a, b);

	// Check if both nodes can be crunshed together.
	if (c[0].table.length + c[1].table.length <= M)
	{
		if (c[0].table.length === 0)
		{
			return c[1];
		}
		if (c[1].table.length === 0)
		{
			return c[0];
		}

		// Adjust .table and .lengths
		c[0].table = c[0].table.concat(c[1].table);
		if (c[0].height > 0)
		{
			var len = length(c[0]);
			for (var i = 0; i < c[1].lengths.length; i++)
			{
				c[1].lengths[i] += len;
			}
			c[0].lengths = c[0].lengths.concat(c[1].lengths);
		}

		return c[0];
	}

	if (c[0].height > 0)
	{
		var toRemove = calcToRemove(a, b);
		if (toRemove > E)
		{
			c = shuffle(c[0], c[1], toRemove);
		}
	}

	return siblise(c[0], c[1]);
}

// Returns an array of two nodes; right and left. One node _may_ be empty.
function append_(a, b)
{
	if (a.height === 0 && b.height === 0)
	{
		return [a, b];
	}

	if (a.height !== 1 || b.height !== 1)
	{
		if (a.height === b.height)
		{
			a = nodeCopy(a);
			b = nodeCopy(b);
			var appended = append_(botRight(a), botLeft(b));

			insertRight(a, appended[1]);
			insertLeft(b, appended[0]);
		}
		else if (a.height > b.height)
		{
			a = nodeCopy(a);
			var appended = append_(botRight(a), b);

			insertRight(a, appended[0]);
			b = parentise(appended[1], appended[1].height + 1);
		}
		else
		{
			b = nodeCopy(b);
			var appended = append_(a, botLeft(b));

			var left = appended[0].table.length === 0 ? 0 : 1;
			var right = left === 0 ? 1 : 0;
			insertLeft(b, appended[left]);
			a = parentise(appended[right], appended[right].height + 1);
		}
	}

	// Check if balancing is needed and return based on that.
	if (a.table.length === 0 || b.table.length === 0)
	{
		return [a, b];
	}

	var toRemove = calcToRemove(a, b);
	if (toRemove <= E)
	{
		return [a, b];
	}
	return shuffle(a, b, toRemove);
}

// Helperfunctions for append_. Replaces a child node at the side of the parent.
function insertRight(parent, node)
{
	var index = parent.table.length - 1;
	parent.table[index] = node;
	parent.lengths[index] = length(node);
	parent.lengths[index] += index > 0 ? parent.lengths[index - 1] : 0;
}

function insertLeft(parent, node)
{
	if (node.table.length > 0)
	{
		parent.table[0] = node;
		parent.lengths[0] = length(node);

		var len = length(parent.table[0]);
		for (var i = 1; i < parent.lengths.length; i++)
		{
			len += length(parent.table[i]);
			parent.lengths[i] = len;
		}
	}
	else
	{
		parent.table.shift();
		for (var i = 1; i < parent.lengths.length; i++)
		{
			parent.lengths[i] = parent.lengths[i] - parent.lengths[0];
		}
		parent.lengths.shift();
	}
}

// Returns the extra search steps for E. Refer to the paper.
function calcToRemove(a, b)
{
	var subLengths = 0;
	for (var i = 0; i < a.table.length; i++)
	{
		subLengths += a.table[i].table.length;
	}
	for (var i = 0; i < b.table.length; i++)
	{
		subLengths += b.table[i].table.length;
	}

	var toRemove = a.table.length + b.table.length;
	return toRemove - (Math.floor((subLengths - 1) / M) + 1);
}

// get2, set2 and saveSlot are helpers for accessing elements over two arrays.
function get2(a, b, index)
{
	return index < a.length
		? a[index]
		: b[index - a.length];
}

function set2(a, b, index, value)
{
	if (index < a.length)
	{
		a[index] = value;
	}
	else
	{
		b[index - a.length] = value;
	}
}

function saveSlot(a, b, index, slot)
{
	set2(a.table, b.table, index, slot);

	var l = (index === 0 || index === a.lengths.length)
		? 0
		: get2(a.lengths, a.lengths, index - 1);

	set2(a.lengths, b.lengths, index, l + length(slot));
}

// Creates a node or leaf with a given length at their arrays for perfomance.
// Is only used by shuffle.
function createNode(h, length)
{
	if (length < 0)
	{
		length = 0;
	}
	var a = {
		ctor: '_Array',
		height: h,
		table: new Array(length)
	};
	if (h > 0)
	{
		a.lengths = new Array(length);
	}
	return a;
}

// Returns an array of two balanced nodes.
function shuffle(a, b, toRemove)
{
	var newA = createNode(a.height, Math.min(M, a.table.length + b.table.length - toRemove));
	var newB = createNode(a.height, newA.table.length - (a.table.length + b.table.length - toRemove));

	// Skip the slots with size M. More precise: copy the slot references
	// to the new node
	var read = 0;
	while (get2(a.table, b.table, read).table.length % M === 0)
	{
		set2(newA.table, newB.table, read, get2(a.table, b.table, read));
		set2(newA.lengths, newB.lengths, read, get2(a.lengths, b.lengths, read));
		read++;
	}

	// Pulling items from left to right, caching in a slot before writing
	// it into the new nodes.
	var write = read;
	var slot = new createNode(a.height - 1, 0);
	var from = 0;

	// If the current slot is still containing data, then there will be at
	// least one more write, so we do not break this loop yet.
	while (read - write - (slot.table.length > 0 ? 1 : 0) < toRemove)
	{
		// Find out the max possible items for copying.
		var source = get2(a.table, b.table, read);
		var to = Math.min(M - slot.table.length, source.table.length);

		// Copy and adjust size table.
		slot.table = slot.table.concat(source.table.slice(from, to));
		if (slot.height > 0)
		{
			var len = slot.lengths.length;
			for (var i = len; i < len + to - from; i++)
			{
				slot.lengths[i] = length(slot.table[i]);
				slot.lengths[i] += (i > 0 ? slot.lengths[i - 1] : 0);
			}
		}

		from += to;

		// Only proceed to next slots[i] if the current one was
		// fully copied.
		if (source.table.length <= to)
		{
			read++; from = 0;
		}

		// Only create a new slot if the current one is filled up.
		if (slot.table.length === M)
		{
			saveSlot(newA, newB, write, slot);
			slot = createNode(a.height - 1, 0);
			write++;
		}
	}

	// Cleanup after the loop. Copy the last slot into the new nodes.
	if (slot.table.length > 0)
	{
		saveSlot(newA, newB, write, slot);
		write++;
	}

	// Shift the untouched slots to the left
	while (read < a.table.length + b.table.length )
	{
		saveSlot(newA, newB, write, get2(a.table, b.table, read));
		read++;
		write++;
	}

	return [newA, newB];
}

// Navigation functions
function botRight(a)
{
	return a.table[a.table.length - 1];
}
function botLeft(a)
{
	return a.table[0];
}

// Copies a node for updating. Note that you should not use this if
// only updating only one of "table" or "lengths" for performance reasons.
function nodeCopy(a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice()
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths.slice();
	}
	return newA;
}

// Returns how many items are in the tree.
function length(array)
{
	if (array.height === 0)
	{
		return array.table.length;
	}
	else
	{
		return array.lengths[array.lengths.length - 1];
	}
}

// Calculates in which slot of "table" the item probably is, then
// find the exact slot via forward searching in  "lengths". Returns the index.
function getSlot(i, a)
{
	var slot = i >> (5 * a.height);
	while (a.lengths[slot] <= i)
	{
		slot++;
	}
	return slot;
}

// Recursively creates a tree with a given height containing
// only the given item.
function create(item, h)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: [item]
		};
	}
	return {
		ctor: '_Array',
		height: h,
		table: [create(item, h - 1)],
		lengths: [1]
	};
}

// Recursively creates a tree that contains the given tree.
function parentise(tree, h)
{
	if (h === tree.height)
	{
		return tree;
	}

	return {
		ctor: '_Array',
		height: h,
		table: [parentise(tree, h - 1)],
		lengths: [length(tree)]
	};
}

// Emphasizes blood brotherhood beneath two trees.
function siblise(a, b)
{
	return {
		ctor: '_Array',
		height: a.height + 1,
		table: [a, b],
		lengths: [length(a), length(a) + length(b)]
	};
}

function toJSArray(a)
{
	var jsArray = new Array(length(a));
	toJSArray_(jsArray, 0, a);
	return jsArray;
}

function toJSArray_(jsArray, i, a)
{
	for (var t = 0; t < a.table.length; t++)
	{
		if (a.height === 0)
		{
			jsArray[i + t] = a.table[t];
		}
		else
		{
			var inc = t === 0 ? 0 : a.lengths[t - 1];
			toJSArray_(jsArray, i + inc, a.table[t]);
		}
	}
}

function fromJSArray(jsArray)
{
	if (jsArray.length === 0)
	{
		return empty;
	}
	var h = Math.floor(Math.log(jsArray.length) / Math.log(M));
	return fromJSArray_(jsArray, h, 0, jsArray.length);
}

function fromJSArray_(jsArray, h, from, to)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: jsArray.slice(from, to)
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = fromJSArray_(jsArray, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i - 1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

return {
	empty: empty,
	fromList: fromList,
	toList: toList,
	initialize: F2(initialize),
	append: F2(append),
	push: F2(push),
	slice: F3(slice),
	get: F2(get),
	set: F3(set),
	map: F2(map),
	indexedMap: F2(indexedMap),
	foldl: F3(foldl),
	foldr: F3(foldr),
	length: length,

	toJSArray: toJSArray,
	fromJSArray: fromJSArray
};

}();
//import Native.Utils //

var _elm_lang$core$Native_Basics = function() {

function div(a, b)
{
	return (a / b) | 0;
}
function rem(a, b)
{
	return a % b;
}
function mod(a, b)
{
	if (b === 0)
	{
		throw new Error('Cannot perform mod 0. Division by zero error.');
	}
	var r = a % b;
	var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r + b) : -mod(-a, -b));

	return m === b ? 0 : m;
}
function logBase(base, n)
{
	return Math.log(n) / Math.log(base);
}
function negate(n)
{
	return -n;
}
function abs(n)
{
	return n < 0 ? -n : n;
}

function min(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) < 0 ? a : b;
}
function max(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) > 0 ? a : b;
}
function clamp(lo, hi, n)
{
	return _elm_lang$core$Native_Utils.cmp(n, lo) < 0
		? lo
		: _elm_lang$core$Native_Utils.cmp(n, hi) > 0
			? hi
			: n;
}

var ord = ['LT', 'EQ', 'GT'];

function compare(x, y)
{
	return { ctor: ord[_elm_lang$core$Native_Utils.cmp(x, y) + 1] };
}

function xor(a, b)
{
	return a !== b;
}
function not(b)
{
	return !b;
}
function isInfinite(n)
{
	return n === Infinity || n === -Infinity;
}

function truncate(n)
{
	return n | 0;
}

function degrees(d)
{
	return d * Math.PI / 180;
}
function turns(t)
{
	return 2 * Math.PI * t;
}
function fromPolar(point)
{
	var r = point._0;
	var t = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(r * Math.cos(t), r * Math.sin(t));
}
function toPolar(point)
{
	var x = point._0;
	var y = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(Math.sqrt(x * x + y * y), Math.atan2(y, x));
}

return {
	div: F2(div),
	rem: F2(rem),
	mod: F2(mod),

	pi: Math.PI,
	e: Math.E,
	cos: Math.cos,
	sin: Math.sin,
	tan: Math.tan,
	acos: Math.acos,
	asin: Math.asin,
	atan: Math.atan,
	atan2: F2(Math.atan2),

	degrees: degrees,
	turns: turns,
	fromPolar: fromPolar,
	toPolar: toPolar,

	sqrt: Math.sqrt,
	logBase: F2(logBase),
	negate: negate,
	abs: abs,
	min: F2(min),
	max: F2(max),
	clamp: F3(clamp),
	compare: F2(compare),

	xor: F2(xor),
	not: not,

	truncate: truncate,
	ceiling: Math.ceil,
	floor: Math.floor,
	round: Math.round,
	toFloat: function(x) { return x; },
	isNaN: isNaN,
	isInfinite: isInfinite
};

}();
//import //

var _elm_lang$core$Native_Utils = function() {

// COMPARISONS

function eq(x, y)
{
	var stack = [];
	var isEqual = eqHelp(x, y, 0, stack);
	var pair;
	while (isEqual && (pair = stack.pop()))
	{
		isEqual = eqHelp(pair.x, pair.y, 0, stack);
	}
	return isEqual;
}


function eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push({ x: x, y: y });
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object')
	{
		if (typeof x === 'function')
		{
			throw new Error(
				'Trying to use `(==)` on functions. There is no way to know if functions are "the same" in the Elm sense.'
				+ ' Read more about this at http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#=='
				+ ' which describes why it is this way and what the better version will look like.'
			);
		}
		return false;
	}

	if (x === null || y === null)
	{
		return false
	}

	if (x instanceof Date)
	{
		return x.getTime() === y.getTime();
	}

	if (!('ctor' in x))
	{
		for (var key in x)
		{
			if (!eqHelp(x[key], y[key], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	// convert Dicts and Sets to lists
	if (x.ctor === 'RBNode_elm_builtin' || x.ctor === 'RBEmpty_elm_builtin')
	{
		x = _elm_lang$core$Dict$toList(x);
		y = _elm_lang$core$Dict$toList(y);
	}
	if (x.ctor === 'Set_elm_builtin')
	{
		x = _elm_lang$core$Set$toList(x);
		y = _elm_lang$core$Set$toList(y);
	}

	// check if lists are equal without recursion
	if (x.ctor === '::')
	{
		var a = x;
		var b = y;
		while (a.ctor === '::' && b.ctor === '::')
		{
			if (!eqHelp(a._0, b._0, depth + 1, stack))
			{
				return false;
			}
			a = a._1;
			b = b._1;
		}
		return a.ctor === b.ctor;
	}

	// check if Arrays are equal
	if (x.ctor === '_Array')
	{
		var xs = _elm_lang$core$Native_Array.toJSArray(x);
		var ys = _elm_lang$core$Native_Array.toJSArray(y);
		if (xs.length !== ys.length)
		{
			return false;
		}
		for (var i = 0; i < xs.length; i++)
		{
			if (!eqHelp(xs[i], ys[i], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	if (!eqHelp(x.ctor, y.ctor, depth + 1, stack))
	{
		return false;
	}

	for (var key in x)
	{
		if (!eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

var LT = -1, EQ = 0, GT = 1;

function cmp(x, y)
{
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? EQ : a < b ? LT : GT;
	}

	if (x.ctor === '::' || x.ctor === '[]')
	{
		while (x.ctor === '::' && y.ctor === '::')
		{
			var ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
		return x.ctor === y.ctor ? EQ : x.ctor === '[]' ? LT : GT;
	}

	if (x.ctor.slice(0, 6) === '_Tuple')
	{
		var ord;
		var n = x.ctor.slice(6) - 0;
		var err = 'cannot compare tuples with more than 6 elements.';
		if (n === 0) return EQ;
		if (n >= 1) { ord = cmp(x._0, y._0); if (ord !== EQ) return ord;
		if (n >= 2) { ord = cmp(x._1, y._1); if (ord !== EQ) return ord;
		if (n >= 3) { ord = cmp(x._2, y._2); if (ord !== EQ) return ord;
		if (n >= 4) { ord = cmp(x._3, y._3); if (ord !== EQ) return ord;
		if (n >= 5) { ord = cmp(x._4, y._4); if (ord !== EQ) return ord;
		if (n >= 6) { ord = cmp(x._5, y._5); if (ord !== EQ) return ord;
		if (n >= 7) throw new Error('Comparison error: ' + err); } } } } } }
		return EQ;
	}

	throw new Error(
		'Comparison error: comparison is only defined on ints, '
		+ 'floats, times, chars, strings, lists of comparable values, '
		+ 'and tuples of comparable values.'
	);
}


// COMMON VALUES

var Tuple0 = {
	ctor: '_Tuple0'
};

function Tuple2(x, y)
{
	return {
		ctor: '_Tuple2',
		_0: x,
		_1: y
	};
}

function chr(c)
{
	return new String(c);
}


// GUID

var count = 0;
function guid(_)
{
	return count++;
}


// RECORDS

function update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


//// LIST STUFF ////

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return {
		ctor: '::',
		_0: hd,
		_1: tl
	};
}

function append(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (xs.ctor === '[]')
	{
		return ys;
	}
	var root = Cons(xs._0, Nil);
	var curr = root;
	xs = xs._1;
	while (xs.ctor !== '[]')
	{
		curr._1 = Cons(xs._0, Nil);
		xs = xs._1;
		curr = curr._1;
	}
	curr._1 = ys;
	return root;
}


// CRASHES

function crash(moduleName, region)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '` ' + regionToString(region) + '\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function crashCase(moduleName, region, value)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '`\n\n'
			+ 'This was caused by the `case` expression ' + regionToString(region) + '.\n'
			+ 'One of the branches ended with a crash and the following value got through:\n\n    ' + toString(value) + '\n\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function regionToString(region)
{
	if (region.start.line == region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'between lines ' + region.start.line + ' and ' + region.end.line;
}


// TO STRING

function toString(v)
{
	var type = typeof v;
	if (type === 'function')
	{
		return '<function>';
	}

	if (type === 'boolean')
	{
		return v ? 'True' : 'False';
	}

	if (type === 'number')
	{
		return v + '';
	}

	if (v instanceof String)
	{
		return '\'' + addSlashes(v, true) + '\'';
	}

	if (type === 'string')
	{
		return '"' + addSlashes(v, false) + '"';
	}

	if (v === null)
	{
		return 'null';
	}

	if (type === 'object' && 'ctor' in v)
	{
		var ctorStarter = v.ctor.substring(0, 5);

		if (ctorStarter === '_Tupl')
		{
			var output = [];
			for (var k in v)
			{
				if (k === 'ctor') continue;
				output.push(toString(v[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (ctorStarter === '_Task')
		{
			return '<task>'
		}

		if (v.ctor === '_Array')
		{
			var list = _elm_lang$core$Array$toList(v);
			return 'Array.fromList ' + toString(list);
		}

		if (v.ctor === '<decoder>')
		{
			return '<decoder>';
		}

		if (v.ctor === '_Process')
		{
			return '<process:' + v.id + '>';
		}

		if (v.ctor === '::')
		{
			var output = '[' + toString(v._0);
			v = v._1;
			while (v.ctor === '::')
			{
				output += ',' + toString(v._0);
				v = v._1;
			}
			return output + ']';
		}

		if (v.ctor === '[]')
		{
			return '[]';
		}

		if (v.ctor === 'Set_elm_builtin')
		{
			return 'Set.fromList ' + toString(_elm_lang$core$Set$toList(v));
		}

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin')
		{
			return 'Dict.fromList ' + toString(_elm_lang$core$Dict$toList(v));
		}

		var output = '';
		for (var i in v)
		{
			if (i === 'ctor') continue;
			var str = toString(v[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return v.ctor + output;
	}

	if (type === 'object')
	{
		if (v instanceof Date)
		{
			return '<' + v.toString() + '>';
		}

		if (v.elm_web_socket)
		{
			return '<websocket>';
		}

		var output = [];
		for (var k in v)
		{
			output.push(k + ' = ' + toString(v[k]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return '<internal structure>';
}

function addSlashes(str, isChar)
{
	var s = str.replace(/\\/g, '\\\\')
			  .replace(/\n/g, '\\n')
			  .replace(/\t/g, '\\t')
			  .replace(/\r/g, '\\r')
			  .replace(/\v/g, '\\v')
			  .replace(/\0/g, '\\0');
	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}


return {
	eq: eq,
	cmp: cmp,
	Tuple0: Tuple0,
	Tuple2: Tuple2,
	chr: chr,
	update: update,
	guid: guid,

	append: F2(append),

	crash: crash,
	crashCase: crashCase,

	toString: toString
};

}();
var _elm_lang$core$Basics$never = function (_p0) {
	never:
	while (true) {
		var _p1 = _p0;
		var _v1 = _p1._0;
		_p0 = _v1;
		continue never;
	}
};
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p2) {
		var _p3 = _p2;
		return A2(f, _p3._0, _p3._1);
	});
var _elm_lang$core$Basics$curry = F3(
	function (f, a, b) {
		return f(
			{ctor: '_Tuple2', _0: a, _1: b});
	});
var _elm_lang$core$Basics$flip = F3(
	function (f, b, a) {
		return A2(f, a, b);
	});
var _elm_lang$core$Basics$always = F2(
	function (a, _p4) {
		return a;
	});
var _elm_lang$core$Basics$identity = function (x) {
	return x;
};
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<|'] = F2(
	function (f, x) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['|>'] = F2(
	function (x, f) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>>'] = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<<'] = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['++'] = _elm_lang$core$Native_Utils.append;
var _elm_lang$core$Basics$toString = _elm_lang$core$Native_Utils.toString;
var _elm_lang$core$Basics$isInfinite = _elm_lang$core$Native_Basics.isInfinite;
var _elm_lang$core$Basics$isNaN = _elm_lang$core$Native_Basics.isNaN;
var _elm_lang$core$Basics$toFloat = _elm_lang$core$Native_Basics.toFloat;
var _elm_lang$core$Basics$ceiling = _elm_lang$core$Native_Basics.ceiling;
var _elm_lang$core$Basics$floor = _elm_lang$core$Native_Basics.floor;
var _elm_lang$core$Basics$truncate = _elm_lang$core$Native_Basics.truncate;
var _elm_lang$core$Basics$round = _elm_lang$core$Native_Basics.round;
var _elm_lang$core$Basics$not = _elm_lang$core$Native_Basics.not;
var _elm_lang$core$Basics$xor = _elm_lang$core$Native_Basics.xor;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['||'] = _elm_lang$core$Native_Basics.or;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['&&'] = _elm_lang$core$Native_Basics.and;
var _elm_lang$core$Basics$max = _elm_lang$core$Native_Basics.max;
var _elm_lang$core$Basics$min = _elm_lang$core$Native_Basics.min;
var _elm_lang$core$Basics$compare = _elm_lang$core$Native_Basics.compare;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>='] = _elm_lang$core$Native_Basics.ge;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<='] = _elm_lang$core$Native_Basics.le;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>'] = _elm_lang$core$Native_Basics.gt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<'] = _elm_lang$core$Native_Basics.lt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/='] = _elm_lang$core$Native_Basics.neq;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['=='] = _elm_lang$core$Native_Basics.eq;
var _elm_lang$core$Basics$e = _elm_lang$core$Native_Basics.e;
var _elm_lang$core$Basics$pi = _elm_lang$core$Native_Basics.pi;
var _elm_lang$core$Basics$clamp = _elm_lang$core$Native_Basics.clamp;
var _elm_lang$core$Basics$logBase = _elm_lang$core$Native_Basics.logBase;
var _elm_lang$core$Basics$abs = _elm_lang$core$Native_Basics.abs;
var _elm_lang$core$Basics$negate = _elm_lang$core$Native_Basics.negate;
var _elm_lang$core$Basics$sqrt = _elm_lang$core$Native_Basics.sqrt;
var _elm_lang$core$Basics$atan2 = _elm_lang$core$Native_Basics.atan2;
var _elm_lang$core$Basics$atan = _elm_lang$core$Native_Basics.atan;
var _elm_lang$core$Basics$asin = _elm_lang$core$Native_Basics.asin;
var _elm_lang$core$Basics$acos = _elm_lang$core$Native_Basics.acos;
var _elm_lang$core$Basics$tan = _elm_lang$core$Native_Basics.tan;
var _elm_lang$core$Basics$sin = _elm_lang$core$Native_Basics.sin;
var _elm_lang$core$Basics$cos = _elm_lang$core$Native_Basics.cos;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['^'] = _elm_lang$core$Native_Basics.exp;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['%'] = _elm_lang$core$Native_Basics.mod;
var _elm_lang$core$Basics$rem = _elm_lang$core$Native_Basics.rem;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['//'] = _elm_lang$core$Native_Basics.div;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/'] = _elm_lang$core$Native_Basics.floatDiv;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['*'] = _elm_lang$core$Native_Basics.mul;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['-'] = _elm_lang$core$Native_Basics.sub;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['+'] = _elm_lang$core$Native_Basics.add;
var _elm_lang$core$Basics$toPolar = _elm_lang$core$Native_Basics.toPolar;
var _elm_lang$core$Basics$fromPolar = _elm_lang$core$Native_Basics.fromPolar;
var _elm_lang$core$Basics$turns = _elm_lang$core$Native_Basics.turns;
var _elm_lang$core$Basics$degrees = _elm_lang$core$Native_Basics.degrees;
var _elm_lang$core$Basics$radians = function (t) {
	return t;
};
var _elm_lang$core$Basics$GT = {ctor: 'GT'};
var _elm_lang$core$Basics$EQ = {ctor: 'EQ'};
var _elm_lang$core$Basics$LT = {ctor: 'LT'};
var _elm_lang$core$Basics$JustOneMore = function (a) {
	return {ctor: 'JustOneMore', _0: a};
};

var _elm_lang$core$Maybe$withDefault = F2(
	function ($default, maybe) {
		var _p0 = maybe;
		if (_p0.ctor === 'Just') {
			return _p0._0;
		} else {
			return $default;
		}
	});
var _elm_lang$core$Maybe$Nothing = {ctor: 'Nothing'};
var _elm_lang$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		var _p1 = maybeValue;
		if (_p1.ctor === 'Just') {
			return callback(_p1._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p2 = maybe;
		if (_p2.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p3 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p3.ctor === '_Tuple2') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p3._0._0, _p3._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p4 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p4.ctor === '_Tuple3') && (_p4._0.ctor === 'Just')) && (_p4._1.ctor === 'Just')) && (_p4._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p4._0._0, _p4._1._0, _p4._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p5 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p5.ctor === '_Tuple4') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === 'Just')) && (_p5._2.ctor === 'Just')) && (_p5._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p5._0._0, _p5._1._0, _p5._2._0, _p5._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p6 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p6.ctor === '_Tuple5') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) && (_p6._2.ctor === 'Just')) && (_p6._3.ctor === 'Just')) && (_p6._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0, _p6._4._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});

//import Native.Utils //

var _elm_lang$core$Native_List = function() {

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return { ctor: '::', _0: hd, _1: tl };
}

function fromArray(arr)
{
	var out = Nil;
	for (var i = arr.length; i--; )
	{
		out = Cons(arr[i], out);
	}
	return out;
}

function toArray(xs)
{
	var out = [];
	while (xs.ctor !== '[]')
	{
		out.push(xs._0);
		xs = xs._1;
	}
	return out;
}

function foldr(f, b, xs)
{
	var arr = toArray(xs);
	var acc = b;
	for (var i = arr.length; i--; )
	{
		acc = A2(f, arr[i], acc);
	}
	return acc;
}

function map2(f, xs, ys)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]')
	{
		arr.push(A2(f, xs._0, ys._0));
		xs = xs._1;
		ys = ys._1;
	}
	return fromArray(arr);
}

function map3(f, xs, ys, zs)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]' && zs.ctor !== '[]')
	{
		arr.push(A3(f, xs._0, ys._0, zs._0));
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map4(f, ws, xs, ys, zs)
{
	var arr = [];
	while (   ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A4(f, ws._0, xs._0, ys._0, zs._0));
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map5(f, vs, ws, xs, ys, zs)
{
	var arr = [];
	while (   vs.ctor !== '[]'
		   && ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A5(f, vs._0, ws._0, xs._0, ys._0, zs._0));
		vs = vs._1;
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function sortBy(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		return _elm_lang$core$Native_Utils.cmp(f(a), f(b));
	}));
}

function sortWith(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		var ord = f(a)(b).ctor;
		return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
	}));
}

return {
	Nil: Nil,
	Cons: Cons,
	cons: F2(Cons),
	toArray: toArray,
	fromArray: fromArray,

	foldr: F3(foldr),

	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	sortBy: F2(sortBy),
	sortWith: F2(sortWith)
};

}();
var _elm_lang$core$List$sortWith = _elm_lang$core$Native_List.sortWith;
var _elm_lang$core$List$sortBy = _elm_lang$core$Native_List.sortBy;
var _elm_lang$core$List$sort = function (xs) {
	return A2(_elm_lang$core$List$sortBy, _elm_lang$core$Basics$identity, xs);
};
var _elm_lang$core$List$singleton = function (value) {
	return {
		ctor: '::',
		_0: value,
		_1: {ctor: '[]'}
	};
};
var _elm_lang$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return list;
			} else {
				var _p0 = list;
				if (_p0.ctor === '[]') {
					return list;
				} else {
					var _v1 = n - 1,
						_v2 = _p0._1;
					n = _v1;
					list = _v2;
					continue drop;
				}
			}
		}
	});
var _elm_lang$core$List$map5 = _elm_lang$core$Native_List.map5;
var _elm_lang$core$List$map4 = _elm_lang$core$Native_List.map4;
var _elm_lang$core$List$map3 = _elm_lang$core$Native_List.map3;
var _elm_lang$core$List$map2 = _elm_lang$core$Native_List.map2;
var _elm_lang$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			var _p1 = list;
			if (_p1.ctor === '[]') {
				return false;
			} else {
				if (isOkay(_p1._0)) {
					return true;
				} else {
					var _v4 = isOkay,
						_v5 = _p1._1;
					isOkay = _v4;
					list = _v5;
					continue any;
				}
			}
		}
	});
var _elm_lang$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			_elm_lang$core$List$any,
			function (_p2) {
				return !isOkay(_p2);
			},
			list);
	});
var _elm_lang$core$List$foldr = _elm_lang$core$Native_List.foldr;
var _elm_lang$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			var _p3 = list;
			if (_p3.ctor === '[]') {
				return acc;
			} else {
				var _v7 = func,
					_v8 = A2(func, _p3._0, acc),
					_v9 = _p3._1;
				func = _v7;
				acc = _v8;
				list = _v9;
				continue foldl;
			}
		}
	});
var _elm_lang$core$List$length = function (xs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p4, i) {
				return i + 1;
			}),
		0,
		xs);
};
var _elm_lang$core$List$sum = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x + y;
			}),
		0,
		numbers);
};
var _elm_lang$core$List$product = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x * y;
			}),
		1,
		numbers);
};
var _elm_lang$core$List$maximum = function (list) {
	var _p5 = list;
	if (_p5.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$max, _p5._0, _p5._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$minimum = function (list) {
	var _p6 = list;
	if (_p6.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$min, _p6._0, _p6._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$member = F2(
	function (x, xs) {
		return A2(
			_elm_lang$core$List$any,
			function (a) {
				return _elm_lang$core$Native_Utils.eq(a, x);
			},
			xs);
	});
var _elm_lang$core$List$isEmpty = function (xs) {
	var _p7 = xs;
	if (_p7.ctor === '[]') {
		return true;
	} else {
		return false;
	}
};
var _elm_lang$core$List$tail = function (list) {
	var _p8 = list;
	if (_p8.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p8._1);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$head = function (list) {
	var _p9 = list;
	if (_p9.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p9._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List_ops = _elm_lang$core$List_ops || {};
_elm_lang$core$List_ops['::'] = _elm_lang$core$Native_List.cons;
var _elm_lang$core$List$map = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, acc) {
					return {
						ctor: '::',
						_0: f(x),
						_1: acc
					};
				}),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (front, back) {
				return pred(front) ? {ctor: '::', _0: front, _1: back} : back;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return {ctor: '::', _0: _p10._0, _1: xs};
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return {ctor: '::', _0: x, _1: y};
			}),
		{ctor: '[]'},
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return {
						ctor: '::',
						_0: A2(f, x, _p11._0),
						_1: accAcc
					};
				} else {
					return {ctor: '[]'};
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				{
					ctor: '::',
					_0: b,
					_1: {ctor: '[]'}
				},
				xs));
	});
var _elm_lang$core$List$append = F2(
	function (xs, ys) {
		var _p12 = ys;
		if (_p12.ctor === '[]') {
			return xs;
		} else {
			return A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		{ctor: '[]'},
		lists);
};
var _elm_lang$core$List$concatMap = F2(
	function (f, list) {
		return _elm_lang$core$List$concat(
			A2(_elm_lang$core$List$map, f, list));
	});
var _elm_lang$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _p13) {
				var _p14 = _p13;
				var _p16 = _p14._0;
				var _p15 = _p14._1;
				return pred(x) ? {
					ctor: '_Tuple2',
					_0: {ctor: '::', _0: x, _1: _p16},
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: {ctor: '::', _0: x, _1: _p15}
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			},
			list);
	});
var _elm_lang$core$List$unzip = function (pairs) {
	var step = F2(
		function (_p18, _p17) {
			var _p19 = _p18;
			var _p20 = _p17;
			return {
				ctor: '_Tuple2',
				_0: {ctor: '::', _0: _p19._0, _1: _p20._0},
				_1: {ctor: '::', _0: _p19._1, _1: _p20._1}
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var step = F2(
				function (x, rest) {
					return {
						ctor: '::',
						_0: sep,
						_1: {ctor: '::', _0: x, _1: rest}
					};
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				{ctor: '[]'},
				_p21._1);
			return {ctor: '::', _0: _p21._0, _1: spersed};
		}
	});
var _elm_lang$core$List$takeReverse = F3(
	function (n, list, taken) {
		takeReverse:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return taken;
			} else {
				var _p22 = list;
				if (_p22.ctor === '[]') {
					return taken;
				} else {
					var _v23 = n - 1,
						_v24 = _p22._1,
						_v25 = {ctor: '::', _0: _p22._0, _1: taken};
					n = _v23;
					list = _v24;
					taken = _v25;
					continue takeReverse;
				}
			}
		}
	});
var _elm_lang$core$List$takeTailRec = F2(
	function (n, list) {
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$takeReverse,
				n,
				list,
				{ctor: '[]'}));
	});
var _elm_lang$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return {ctor: '[]'};
		} else {
			var _p23 = {ctor: '_Tuple2', _0: n, _1: list};
			_v26_5:
			do {
				_v26_1:
				do {
					if (_p23.ctor === '_Tuple2') {
						if (_p23._1.ctor === '[]') {
							return list;
						} else {
							if (_p23._1._1.ctor === '::') {
								switch (_p23._0) {
									case 1:
										break _v26_1;
									case 2:
										return {
											ctor: '::',
											_0: _p23._1._0,
											_1: {
												ctor: '::',
												_0: _p23._1._1._0,
												_1: {ctor: '[]'}
											}
										};
									case 3:
										if (_p23._1._1._1.ctor === '::') {
											return {
												ctor: '::',
												_0: _p23._1._0,
												_1: {
													ctor: '::',
													_0: _p23._1._1._0,
													_1: {
														ctor: '::',
														_0: _p23._1._1._1._0,
														_1: {ctor: '[]'}
													}
												}
											};
										} else {
											break _v26_5;
										}
									default:
										if ((_p23._1._1._1.ctor === '::') && (_p23._1._1._1._1.ctor === '::')) {
											var _p28 = _p23._1._1._1._0;
											var _p27 = _p23._1._1._0;
											var _p26 = _p23._1._0;
											var _p25 = _p23._1._1._1._1._0;
											var _p24 = _p23._1._1._1._1._1;
											return (_elm_lang$core$Native_Utils.cmp(ctr, 1000) > 0) ? {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A2(_elm_lang$core$List$takeTailRec, n - 4, _p24)
														}
													}
												}
											} : {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A3(_elm_lang$core$List$takeFast, ctr + 1, n - 4, _p24)
														}
													}
												}
											};
										} else {
											break _v26_5;
										}
								}
							} else {
								if (_p23._0 === 1) {
									break _v26_1;
								} else {
									break _v26_5;
								}
							}
						}
					} else {
						break _v26_5;
					}
				} while(false);
				return {
					ctor: '::',
					_0: _p23._1._0,
					_1: {ctor: '[]'}
				};
			} while(false);
			return list;
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		return A3(_elm_lang$core$List$takeFast, 0, n, list);
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v27 = {ctor: '::', _0: value, _1: result},
					_v28 = n - 1,
					_v29 = value;
				result = _v27;
				n = _v28;
				value = _v29;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			{ctor: '[]'},
			n,
			value);
	});
var _elm_lang$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(lo, hi) < 1) {
				var _v30 = lo,
					_v31 = hi - 1,
					_v32 = {ctor: '::', _0: hi, _1: list};
				lo = _v30;
				hi = _v31;
				list = _v32;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var _elm_lang$core$List$range = F2(
	function (lo, hi) {
		return A3(
			_elm_lang$core$List$rangeHelp,
			lo,
			hi,
			{ctor: '[]'});
	});
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			A2(
				_elm_lang$core$List$range,
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});

var _elm_lang$core$Array$append = _elm_lang$core$Native_Array.append;
var _elm_lang$core$Array$length = _elm_lang$core$Native_Array.length;
var _elm_lang$core$Array$isEmpty = function (array) {
	return _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Array$length(array),
		0);
};
var _elm_lang$core$Array$slice = _elm_lang$core$Native_Array.slice;
var _elm_lang$core$Array$set = _elm_lang$core$Native_Array.set;
var _elm_lang$core$Array$get = F2(
	function (i, array) {
		return ((_elm_lang$core$Native_Utils.cmp(0, i) < 1) && (_elm_lang$core$Native_Utils.cmp(
			i,
			_elm_lang$core$Native_Array.length(array)) < 0)) ? _elm_lang$core$Maybe$Just(
			A2(_elm_lang$core$Native_Array.get, i, array)) : _elm_lang$core$Maybe$Nothing;
	});
var _elm_lang$core$Array$push = _elm_lang$core$Native_Array.push;
var _elm_lang$core$Array$empty = _elm_lang$core$Native_Array.empty;
var _elm_lang$core$Array$filter = F2(
	function (isOkay, arr) {
		var update = F2(
			function (x, xs) {
				return isOkay(x) ? A2(_elm_lang$core$Native_Array.push, x, xs) : xs;
			});
		return A3(_elm_lang$core$Native_Array.foldl, update, _elm_lang$core$Native_Array.empty, arr);
	});
var _elm_lang$core$Array$foldr = _elm_lang$core$Native_Array.foldr;
var _elm_lang$core$Array$foldl = _elm_lang$core$Native_Array.foldl;
var _elm_lang$core$Array$indexedMap = _elm_lang$core$Native_Array.indexedMap;
var _elm_lang$core$Array$map = _elm_lang$core$Native_Array.map;
var _elm_lang$core$Array$toIndexedList = function (array) {
	return A3(
		_elm_lang$core$List$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(
			_elm_lang$core$List$range,
			0,
			_elm_lang$core$Native_Array.length(array) - 1),
		_elm_lang$core$Native_Array.toList(array));
};
var _elm_lang$core$Array$toList = _elm_lang$core$Native_Array.toList;
var _elm_lang$core$Array$fromList = _elm_lang$core$Native_Array.fromList;
var _elm_lang$core$Array$initialize = _elm_lang$core$Native_Array.initialize;
var _elm_lang$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			_elm_lang$core$Array$initialize,
			n,
			_elm_lang$core$Basics$always(e));
	});
var _elm_lang$core$Array$Array = {ctor: 'Array'};

//import Maybe, Native.Array, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_Json = function() {


// CORE DECODERS

function succeed(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'succeed',
		msg: msg
	};
}

function fail(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'fail',
		msg: msg
	};
}

function decodePrimitive(tag)
{
	return {
		ctor: '<decoder>',
		tag: tag
	};
}

function decodeContainer(tag, decoder)
{
	return {
		ctor: '<decoder>',
		tag: tag,
		decoder: decoder
	};
}

function decodeNull(value)
{
	return {
		ctor: '<decoder>',
		tag: 'null',
		value: value
	};
}

function decodeField(field, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'field',
		field: field,
		decoder: decoder
	};
}

function decodeIndex(index, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'index',
		index: index,
		decoder: decoder
	};
}

function decodeKeyValuePairs(decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'key-value',
		decoder: decoder
	};
}

function mapMany(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'map-many',
		func: f,
		decoders: decoders
	};
}

function andThen(callback, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'andThen',
		decoder: decoder,
		callback: callback
	};
}

function oneOf(decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'oneOf',
		decoders: decoders
	};
}


// DECODING OBJECTS

function map1(f, d1)
{
	return mapMany(f, [d1]);
}

function map2(f, d1, d2)
{
	return mapMany(f, [d1, d2]);
}

function map3(f, d1, d2, d3)
{
	return mapMany(f, [d1, d2, d3]);
}

function map4(f, d1, d2, d3, d4)
{
	return mapMany(f, [d1, d2, d3, d4]);
}

function map5(f, d1, d2, d3, d4, d5)
{
	return mapMany(f, [d1, d2, d3, d4, d5]);
}

function map6(f, d1, d2, d3, d4, d5, d6)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6]);
}

function map7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function map8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
}


// DECODE HELPERS

function ok(value)
{
	return { tag: 'ok', value: value };
}

function badPrimitive(type, value)
{
	return { tag: 'primitive', type: type, value: value };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badField(field, nestedProblems)
{
	return { tag: 'field', field: field, rest: nestedProblems };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badOneOf(problems)
{
	return { tag: 'oneOf', problems: problems };
}

function bad(msg)
{
	return { tag: 'fail', msg: msg };
}

function badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case 'primitive':
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + jsToString(problem.value);

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'field':
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case 'oneOf':
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case 'fail':
				return 'I ran into a `fail` decoder'
					+ (context === '_' ? '' : ' at ' + context)
					+ ': ' + problem.msg;
		}
	}
}

function jsToString(value)
{
	return value === undefined
		? 'undefined'
		: JSON.stringify(value);
}


// DECODE

function runOnString(decoder, string)
{
	var json;
	try
	{
		json = JSON.parse(string);
	}
	catch (e)
	{
		return _elm_lang$core$Result$Err('Given an invalid JSON: ' + e.message);
	}
	return run(decoder, json);
}

function run(decoder, value)
{
	var result = runHelp(decoder, value);
	return (result.tag === 'ok')
		? _elm_lang$core$Result$Ok(result.value)
		: _elm_lang$core$Result$Err(badToString(result));
}

function runHelp(decoder, value)
{
	switch (decoder.tag)
	{
		case 'bool':
			return (typeof value === 'boolean')
				? ok(value)
				: badPrimitive('a Bool', value);

		case 'int':
			if (typeof value !== 'number') {
				return badPrimitive('an Int', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return ok(value);
			}

			return badPrimitive('an Int', value);

		case 'float':
			return (typeof value === 'number')
				? ok(value)
				: badPrimitive('a Float', value);

		case 'string':
			return (typeof value === 'string')
				? ok(value)
				: (value instanceof String)
					? ok(value + '')
					: badPrimitive('a String', value);

		case 'null':
			return (value === null)
				? ok(decoder.value)
				: badPrimitive('null', value);

		case 'value':
			return ok(value);

		case 'list':
			if (!(value instanceof Array))
			{
				return badPrimitive('a List', value);
			}

			var list = _elm_lang$core$Native_List.Nil;
			for (var i = value.length; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result)
				}
				list = _elm_lang$core$Native_List.Cons(result.value, list);
			}
			return ok(list);

		case 'array':
			if (!(value instanceof Array))
			{
				return badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result);
				}
				array[i] = result.value;
			}
			return ok(_elm_lang$core$Native_Array.fromJSArray(array));

		case 'maybe':
			var result = runHelp(decoder.decoder, value);
			return (result.tag === 'ok')
				? ok(_elm_lang$core$Maybe$Just(result.value))
				: ok(_elm_lang$core$Maybe$Nothing);

		case 'field':
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = runHelp(decoder.decoder, value[field]);
			return (result.tag === 'ok') ? result : badField(field, result);

		case 'index':
			var index = decoder.index;
			if (!(value instanceof Array))
			{
				return badPrimitive('an array', value);
			}
			if (index >= value.length)
			{
				return badPrimitive('a longer array. Need index ' + index + ' but there are only ' + value.length + ' entries', value);
			}

			var result = runHelp(decoder.decoder, value[index]);
			return (result.tag === 'ok') ? result : badIndex(index, result);

		case 'key-value':
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return badPrimitive('an object', value);
			}

			var keyValuePairs = _elm_lang$core$Native_List.Nil;
			for (var key in value)
			{
				var result = runHelp(decoder.decoder, value[key]);
				if (result.tag !== 'ok')
				{
					return badField(key, result);
				}
				var pair = _elm_lang$core$Native_Utils.Tuple2(key, result.value);
				keyValuePairs = _elm_lang$core$Native_List.Cons(pair, keyValuePairs);
			}
			return ok(keyValuePairs);

		case 'map-many':
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = runHelp(decoders[i], value);
				if (result.tag !== 'ok')
				{
					return result;
				}
				answer = answer(result.value);
			}
			return ok(answer);

		case 'andThen':
			var result = runHelp(decoder.decoder, value);
			return (result.tag !== 'ok')
				? result
				: runHelp(decoder.callback(result.value), value);

		case 'oneOf':
			var errors = [];
			var temp = decoder.decoders;
			while (temp.ctor !== '[]')
			{
				var result = runHelp(temp._0, value);

				if (result.tag === 'ok')
				{
					return result;
				}

				errors.push(result);

				temp = temp._1;
			}
			return badOneOf(errors);

		case 'fail':
			return bad(decoder.msg);

		case 'succeed':
			return ok(decoder.msg);
	}
}


// EQUALITY

function equality(a, b)
{
	if (a === b)
	{
		return true;
	}

	if (a.tag !== b.tag)
	{
		return false;
	}

	switch (a.tag)
	{
		case 'succeed':
		case 'fail':
			return a.msg === b.msg;

		case 'bool':
		case 'int':
		case 'float':
		case 'string':
		case 'value':
			return true;

		case 'null':
			return a.value === b.value;

		case 'list':
		case 'array':
		case 'maybe':
		case 'key-value':
			return equality(a.decoder, b.decoder);

		case 'field':
			return a.field === b.field && equality(a.decoder, b.decoder);

		case 'index':
			return a.index === b.index && equality(a.decoder, b.decoder);

		case 'map-many':
			if (a.func !== b.func)
			{
				return false;
			}
			return listEquality(a.decoders, b.decoders);

		case 'andThen':
			return a.callback === b.callback && equality(a.decoder, b.decoder);

		case 'oneOf':
			return listEquality(a.decoders, b.decoders);
	}
}

function listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

function encode(indentLevel, value)
{
	return JSON.stringify(value, null, indentLevel);
}

function identity(value)
{
	return value;
}

function encodeObject(keyValuePairs)
{
	var obj = {};
	while (keyValuePairs.ctor !== '[]')
	{
		var pair = keyValuePairs._0;
		obj[pair._0] = pair._1;
		keyValuePairs = keyValuePairs._1;
	}
	return obj;
}

return {
	encode: F2(encode),
	runOnString: F2(runOnString),
	run: F2(run),

	decodeNull: decodeNull,
	decodePrimitive: decodePrimitive,
	decodeContainer: F2(decodeContainer),

	decodeField: F2(decodeField),
	decodeIndex: F2(decodeIndex),

	map1: F2(map1),
	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	map6: F7(map6),
	map7: F8(map7),
	map8: F9(map8),
	decodeKeyValuePairs: decodeKeyValuePairs,

	andThen: F2(andThen),
	fail: fail,
	succeed: succeed,
	oneOf: oneOf,

	identity: identity,
	encodeNull: null,
	encodeArray: _elm_lang$core$Native_Array.toJSArray,
	encodeList: _elm_lang$core$Native_List.toArray,
	encodeObject: encodeObject,

	equality: equality
};

}();

var _elm_lang$core$Json_Encode$list = _elm_lang$core$Native_Json.encodeList;
var _elm_lang$core$Json_Encode$array = _elm_lang$core$Native_Json.encodeArray;
var _elm_lang$core$Json_Encode$object = _elm_lang$core$Native_Json.encodeObject;
var _elm_lang$core$Json_Encode$null = _elm_lang$core$Native_Json.encodeNull;
var _elm_lang$core$Json_Encode$bool = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$float = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$int = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$string = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$encode = _elm_lang$core$Native_Json.encode;
var _elm_lang$core$Json_Encode$Value = {ctor: 'Value'};

//import Native.Utils //

var _elm_lang$core$Native_Debug = function() {

function log(tag, value)
{
	var msg = tag + ': ' + _elm_lang$core$Native_Utils.toString(value);
	var process = process || {};
	if (process.stdout)
	{
		process.stdout.write(msg);
	}
	else
	{
		console.log(msg);
	}
	return value;
}

function crash(message)
{
	throw new Error(message);
}

return {
	crash: crash,
	log: F2(log)
};

}();
//import Maybe, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_String = function() {

function isEmpty(str)
{
	return str.length === 0;
}
function cons(chr, str)
{
	return chr + str;
}
function uncons(str)
{
	var hd = str[0];
	if (hd)
	{
		return _elm_lang$core$Maybe$Just(_elm_lang$core$Native_Utils.Tuple2(_elm_lang$core$Native_Utils.chr(hd), str.slice(1)));
	}
	return _elm_lang$core$Maybe$Nothing;
}
function append(a, b)
{
	return a + b;
}
function concat(strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join('');
}
function length(str)
{
	return str.length;
}
function map(f, str)
{
	var out = str.split('');
	for (var i = out.length; i--; )
	{
		out[i] = f(_elm_lang$core$Native_Utils.chr(out[i]));
	}
	return out.join('');
}
function filter(pred, str)
{
	return str.split('').map(_elm_lang$core$Native_Utils.chr).filter(pred).join('');
}
function reverse(str)
{
	return str.split('').reverse().join('');
}
function foldl(f, b, str)
{
	var len = str.length;
	for (var i = 0; i < len; ++i)
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function foldr(f, b, str)
{
	for (var i = str.length; i--; )
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function split(sep, str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(sep));
}
function join(sep, strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join(sep);
}
function repeat(n, str)
{
	var result = '';
	while (n > 0)
	{
		if (n & 1)
		{
			result += str;
		}
		n >>= 1, str += str;
	}
	return result;
}
function slice(start, end, str)
{
	return str.slice(start, end);
}
function left(n, str)
{
	return n < 1 ? '' : str.slice(0, n);
}
function right(n, str)
{
	return n < 1 ? '' : str.slice(-n);
}
function dropLeft(n, str)
{
	return n < 1 ? str : str.slice(n);
}
function dropRight(n, str)
{
	return n < 1 ? str : str.slice(0, -n);
}
function pad(n, chr, str)
{
	var half = (n - str.length) / 2;
	return repeat(Math.ceil(half), chr) + str + repeat(half | 0, chr);
}
function padRight(n, chr, str)
{
	return str + repeat(n - str.length, chr);
}
function padLeft(n, chr, str)
{
	return repeat(n - str.length, chr) + str;
}

function trim(str)
{
	return str.trim();
}
function trimLeft(str)
{
	return str.replace(/^\s+/, '');
}
function trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function words(str)
{
	return _elm_lang$core$Native_List.fromArray(str.trim().split(/\s+/g));
}
function lines(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(/\r\n|\r|\n/g));
}

function toUpper(str)
{
	return str.toUpperCase();
}
function toLower(str)
{
	return str.toLowerCase();
}

function any(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return true;
		}
	}
	return false;
}
function all(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (!pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return false;
		}
	}
	return true;
}

function contains(sub, str)
{
	return str.indexOf(sub) > -1;
}
function startsWith(sub, str)
{
	return str.indexOf(sub) === 0;
}
function endsWith(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
}
function indexes(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _elm_lang$core$Native_List.Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _elm_lang$core$Native_List.fromArray(is);
}


function toInt(s)
{
	var len = s.length;

	// if empty
	if (len === 0)
	{
		return intErr(s);
	}

	// if hex
	var c = s[0];
	if (c === '0' && s[1] === 'x')
	{
		for (var i = 2; i < len; ++i)
		{
			var c = s[i];
			if (('0' <= c && c <= '9') || ('A' <= c && c <= 'F') || ('a' <= c && c <= 'f'))
			{
				continue;
			}
			return intErr(s);
		}
		return _elm_lang$core$Result$Ok(parseInt(s, 16));
	}

	// is decimal
	if (c > '9' || (c < '0' && c !== '-' && c !== '+'))
	{
		return intErr(s);
	}
	for (var i = 1; i < len; ++i)
	{
		var c = s[i];
		if (c < '0' || '9' < c)
		{
			return intErr(s);
		}
	}

	return _elm_lang$core$Result$Ok(parseInt(s, 10));
}

function intErr(s)
{
	return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int");
}


function toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return floatErr(s);
	}
	var n = +s;
	// faster isNaN check
	return n === n ? _elm_lang$core$Result$Ok(n) : floatErr(s);
}

function floatErr(s)
{
	return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float");
}


function toList(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split('').map(_elm_lang$core$Native_Utils.chr));
}
function fromList(chars)
{
	return _elm_lang$core$Native_List.toArray(chars).join('');
}

return {
	isEmpty: isEmpty,
	cons: F2(cons),
	uncons: uncons,
	append: F2(append),
	concat: concat,
	length: length,
	map: F2(map),
	filter: F2(filter),
	reverse: reverse,
	foldl: F3(foldl),
	foldr: F3(foldr),

	split: F2(split),
	join: F2(join),
	repeat: F2(repeat),

	slice: F3(slice),
	left: F2(left),
	right: F2(right),
	dropLeft: F2(dropLeft),
	dropRight: F2(dropRight),

	pad: F3(pad),
	padLeft: F3(padLeft),
	padRight: F3(padRight),

	trim: trim,
	trimLeft: trimLeft,
	trimRight: trimRight,

	words: words,
	lines: lines,

	toUpper: toUpper,
	toLower: toLower,

	any: F2(any),
	all: F2(all),

	contains: F2(contains),
	startsWith: F2(startsWith),
	endsWith: F2(endsWith),
	indexes: F2(indexes),

	toInt: toInt,
	toFloat: toFloat,
	toList: toList,
	fromList: fromList
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

return {
	fromCode: function(c) { return _elm_lang$core$Native_Utils.chr(String.fromCharCode(c)); },
	toCode: function(c) { return c.charCodeAt(0); },
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();
var _elm_lang$core$Char$fromCode = _elm_lang$core$Native_Char.fromCode;
var _elm_lang$core$Char$toCode = _elm_lang$core$Native_Char.toCode;
var _elm_lang$core$Char$toLocaleLower = _elm_lang$core$Native_Char.toLocaleLower;
var _elm_lang$core$Char$toLocaleUpper = _elm_lang$core$Native_Char.toLocaleUpper;
var _elm_lang$core$Char$toLower = _elm_lang$core$Native_Char.toLower;
var _elm_lang$core$Char$toUpper = _elm_lang$core$Native_Char.toUpper;
var _elm_lang$core$Char$isBetween = F3(
	function (low, high, $char) {
		var code = _elm_lang$core$Char$toCode($char);
		return (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(low)) > -1) && (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(high)) < 1);
	});
var _elm_lang$core$Char$isUpper = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('A'),
	_elm_lang$core$Native_Utils.chr('Z'));
var _elm_lang$core$Char$isLower = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('a'),
	_elm_lang$core$Native_Utils.chr('z'));
var _elm_lang$core$Char$isDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('9'));
var _elm_lang$core$Char$isOctDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('7'));
var _elm_lang$core$Char$isHexDigit = function ($char) {
	return _elm_lang$core$Char$isDigit($char) || (A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('a'),
		_elm_lang$core$Native_Utils.chr('f'),
		$char) || A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('A'),
		_elm_lang$core$Native_Utils.chr('F'),
		$char));
};

var _elm_lang$core$Result$toMaybe = function (result) {
	var _p0 = result;
	if (_p0.ctor === 'Ok') {
		return _elm_lang$core$Maybe$Just(_p0._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$Result$withDefault = F2(
	function (def, result) {
		var _p1 = result;
		if (_p1.ctor === 'Ok') {
			return _p1._0;
		} else {
			return def;
		}
	});
var _elm_lang$core$Result$Err = function (a) {
	return {ctor: 'Err', _0: a};
};
var _elm_lang$core$Result$andThen = F2(
	function (callback, result) {
		var _p2 = result;
		if (_p2.ctor === 'Ok') {
			return callback(_p2._0);
		} else {
			return _elm_lang$core$Result$Err(_p2._0);
		}
	});
var _elm_lang$core$Result$Ok = function (a) {
	return {ctor: 'Ok', _0: a};
};
var _elm_lang$core$Result$map = F2(
	function (func, ra) {
		var _p3 = ra;
		if (_p3.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(
				func(_p3._0));
		} else {
			return _elm_lang$core$Result$Err(_p3._0);
		}
	});
var _elm_lang$core$Result$map2 = F3(
	function (func, ra, rb) {
		var _p4 = {ctor: '_Tuple2', _0: ra, _1: rb};
		if (_p4._0.ctor === 'Ok') {
			if (_p4._1.ctor === 'Ok') {
				return _elm_lang$core$Result$Ok(
					A2(func, _p4._0._0, _p4._1._0));
			} else {
				return _elm_lang$core$Result$Err(_p4._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p4._0._0);
		}
	});
var _elm_lang$core$Result$map3 = F4(
	function (func, ra, rb, rc) {
		var _p5 = {ctor: '_Tuple3', _0: ra, _1: rb, _2: rc};
		if (_p5._0.ctor === 'Ok') {
			if (_p5._1.ctor === 'Ok') {
				if (_p5._2.ctor === 'Ok') {
					return _elm_lang$core$Result$Ok(
						A3(func, _p5._0._0, _p5._1._0, _p5._2._0));
				} else {
					return _elm_lang$core$Result$Err(_p5._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p5._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p5._0._0);
		}
	});
var _elm_lang$core$Result$map4 = F5(
	function (func, ra, rb, rc, rd) {
		var _p6 = {ctor: '_Tuple4', _0: ra, _1: rb, _2: rc, _3: rd};
		if (_p6._0.ctor === 'Ok') {
			if (_p6._1.ctor === 'Ok') {
				if (_p6._2.ctor === 'Ok') {
					if (_p6._3.ctor === 'Ok') {
						return _elm_lang$core$Result$Ok(
							A4(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0));
					} else {
						return _elm_lang$core$Result$Err(_p6._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p6._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p6._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p6._0._0);
		}
	});
var _elm_lang$core$Result$map5 = F6(
	function (func, ra, rb, rc, rd, re) {
		var _p7 = {ctor: '_Tuple5', _0: ra, _1: rb, _2: rc, _3: rd, _4: re};
		if (_p7._0.ctor === 'Ok') {
			if (_p7._1.ctor === 'Ok') {
				if (_p7._2.ctor === 'Ok') {
					if (_p7._3.ctor === 'Ok') {
						if (_p7._4.ctor === 'Ok') {
							return _elm_lang$core$Result$Ok(
								A5(func, _p7._0._0, _p7._1._0, _p7._2._0, _p7._3._0, _p7._4._0));
						} else {
							return _elm_lang$core$Result$Err(_p7._4._0);
						}
					} else {
						return _elm_lang$core$Result$Err(_p7._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p7._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p7._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p7._0._0);
		}
	});
var _elm_lang$core$Result$mapError = F2(
	function (f, result) {
		var _p8 = result;
		if (_p8.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(_p8._0);
		} else {
			return _elm_lang$core$Result$Err(
				f(_p8._0));
		}
	});
var _elm_lang$core$Result$fromMaybe = F2(
	function (err, maybe) {
		var _p9 = maybe;
		if (_p9.ctor === 'Just') {
			return _elm_lang$core$Result$Ok(_p9._0);
		} else {
			return _elm_lang$core$Result$Err(err);
		}
	});

var _elm_lang$core$String$fromList = _elm_lang$core$Native_String.fromList;
var _elm_lang$core$String$toList = _elm_lang$core$Native_String.toList;
var _elm_lang$core$String$toFloat = _elm_lang$core$Native_String.toFloat;
var _elm_lang$core$String$toInt = _elm_lang$core$Native_String.toInt;
var _elm_lang$core$String$indices = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$indexes = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$endsWith = _elm_lang$core$Native_String.endsWith;
var _elm_lang$core$String$startsWith = _elm_lang$core$Native_String.startsWith;
var _elm_lang$core$String$contains = _elm_lang$core$Native_String.contains;
var _elm_lang$core$String$all = _elm_lang$core$Native_String.all;
var _elm_lang$core$String$any = _elm_lang$core$Native_String.any;
var _elm_lang$core$String$toLower = _elm_lang$core$Native_String.toLower;
var _elm_lang$core$String$toUpper = _elm_lang$core$Native_String.toUpper;
var _elm_lang$core$String$lines = _elm_lang$core$Native_String.lines;
var _elm_lang$core$String$words = _elm_lang$core$Native_String.words;
var _elm_lang$core$String$trimRight = _elm_lang$core$Native_String.trimRight;
var _elm_lang$core$String$trimLeft = _elm_lang$core$Native_String.trimLeft;
var _elm_lang$core$String$trim = _elm_lang$core$Native_String.trim;
var _elm_lang$core$String$padRight = _elm_lang$core$Native_String.padRight;
var _elm_lang$core$String$padLeft = _elm_lang$core$Native_String.padLeft;
var _elm_lang$core$String$pad = _elm_lang$core$Native_String.pad;
var _elm_lang$core$String$dropRight = _elm_lang$core$Native_String.dropRight;
var _elm_lang$core$String$dropLeft = _elm_lang$core$Native_String.dropLeft;
var _elm_lang$core$String$right = _elm_lang$core$Native_String.right;
var _elm_lang$core$String$left = _elm_lang$core$Native_String.left;
var _elm_lang$core$String$slice = _elm_lang$core$Native_String.slice;
var _elm_lang$core$String$repeat = _elm_lang$core$Native_String.repeat;
var _elm_lang$core$String$join = _elm_lang$core$Native_String.join;
var _elm_lang$core$String$split = _elm_lang$core$Native_String.split;
var _elm_lang$core$String$foldr = _elm_lang$core$Native_String.foldr;
var _elm_lang$core$String$foldl = _elm_lang$core$Native_String.foldl;
var _elm_lang$core$String$reverse = _elm_lang$core$Native_String.reverse;
var _elm_lang$core$String$filter = _elm_lang$core$Native_String.filter;
var _elm_lang$core$String$map = _elm_lang$core$Native_String.map;
var _elm_lang$core$String$length = _elm_lang$core$Native_String.length;
var _elm_lang$core$String$concat = _elm_lang$core$Native_String.concat;
var _elm_lang$core$String$append = _elm_lang$core$Native_String.append;
var _elm_lang$core$String$uncons = _elm_lang$core$Native_String.uncons;
var _elm_lang$core$String$cons = _elm_lang$core$Native_String.cons;
var _elm_lang$core$String$fromChar = function ($char) {
	return A2(_elm_lang$core$String$cons, $char, '');
};
var _elm_lang$core$String$isEmpty = _elm_lang$core$Native_String.isEmpty;

var _elm_lang$core$Dict$foldr = F3(
	function (f, acc, t) {
		foldr:
		while (true) {
			var _p0 = t;
			if (_p0.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v1 = f,
					_v2 = A3(
					f,
					_p0._1,
					_p0._2,
					A3(_elm_lang$core$Dict$foldr, f, acc, _p0._4)),
					_v3 = _p0._3;
				f = _v1;
				acc = _v2;
				t = _v3;
				continue foldr;
			}
		}
	});
var _elm_lang$core$Dict$keys = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return {ctor: '::', _0: key, _1: keyList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return {ctor: '::', _0: value, _1: valueList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: key, _1: value},
					_1: list
				};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			var _p1 = dict;
			if (_p1.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v5 = f,
					_v6 = A3(
					f,
					_p1._1,
					_p1._2,
					A3(_elm_lang$core$Dict$foldl, f, acc, _p1._3)),
					_v7 = _p1._4;
				f = _v5;
				acc = _v6;
				dict = _v7;
				continue foldl;
			}
		}
	});
var _elm_lang$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _p2) {
				stepState:
				while (true) {
					var _p3 = _p2;
					var _p9 = _p3._1;
					var _p8 = _p3._0;
					var _p4 = _p8;
					if (_p4.ctor === '[]') {
						return {
							ctor: '_Tuple2',
							_0: _p8,
							_1: A3(rightStep, rKey, rValue, _p9)
						};
					} else {
						var _p7 = _p4._1;
						var _p6 = _p4._0._1;
						var _p5 = _p4._0._0;
						if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) {
							var _v10 = rKey,
								_v11 = rValue,
								_v12 = {
								ctor: '_Tuple2',
								_0: _p7,
								_1: A3(leftStep, _p5, _p6, _p9)
							};
							rKey = _v10;
							rValue = _v11;
							_p2 = _v12;
							continue stepState;
						} else {
							if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) {
								return {
									ctor: '_Tuple2',
									_0: _p8,
									_1: A3(rightStep, rKey, rValue, _p9)
								};
							} else {
								return {
									ctor: '_Tuple2',
									_0: _p7,
									_1: A4(bothStep, _p5, _p6, rValue, _p9)
								};
							}
						}
					}
				}
			});
		var _p10 = A3(
			_elm_lang$core$Dict$foldl,
			stepState,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Dict$toList(leftDict),
				_1: initialResult
			},
			rightDict);
		var leftovers = _p10._0;
		var intermediateResult = _p10._1;
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (_p11, result) {
					var _p12 = _p11;
					return A3(leftStep, _p12._0, _p12._1, result);
				}),
			intermediateResult,
			leftovers);
	});
var _elm_lang$core$Dict$reportRemBug = F4(
	function (msg, c, lgot, rgot) {
		return _elm_lang$core$Native_Debug.crash(
			_elm_lang$core$String$concat(
				{
					ctor: '::',
					_0: 'Internal red-black tree invariant violated, expected ',
					_1: {
						ctor: '::',
						_0: msg,
						_1: {
							ctor: '::',
							_0: ' and got ',
							_1: {
								ctor: '::',
								_0: _elm_lang$core$Basics$toString(c),
								_1: {
									ctor: '::',
									_0: '/',
									_1: {
										ctor: '::',
										_0: lgot,
										_1: {
											ctor: '::',
											_0: '/',
											_1: {
												ctor: '::',
												_0: rgot,
												_1: {
													ctor: '::',
													_0: '\nPlease report this bug to <https://github.com/elm-lang/core/issues>',
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}
				}));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v14_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v14_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v14_2;
			}
		}
	} while(false);
	return false;
};
var _elm_lang$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			var _p14 = dict;
			if (_p14.ctor === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var _v16 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v17 = _p14._3;
				n = _v16;
				dict = _v17;
				continue sizeHelp;
			}
		}
	});
var _elm_lang$core$Dict$size = function (dict) {
	return A2(_elm_lang$core$Dict$sizeHelp, 0, dict);
};
var _elm_lang$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			var _p15 = dict;
			if (_p15.ctor === 'RBEmpty_elm_builtin') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p16 = A2(_elm_lang$core$Basics$compare, targetKey, _p15._1);
				switch (_p16.ctor) {
					case 'LT':
						var _v20 = targetKey,
							_v21 = _p15._3;
						targetKey = _v20;
						dict = _v21;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v22 = targetKey,
							_v23 = _p15._4;
						targetKey = _v22;
						dict = _v23;
						continue get;
				}
			}
		}
	});
var _elm_lang$core$Dict$member = F2(
	function (key, dict) {
		var _p17 = A2(_elm_lang$core$Dict$get, key, dict);
		if (_p17.ctor === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var _elm_lang$core$Dict$maxWithDefault = F3(
	function (k, v, r) {
		maxWithDefault:
		while (true) {
			var _p18 = r;
			if (_p18.ctor === 'RBEmpty_elm_builtin') {
				return {ctor: '_Tuple2', _0: k, _1: v};
			} else {
				var _v26 = _p18._1,
					_v27 = _p18._2,
					_v28 = _p18._4;
				k = _v26;
				v = _v27;
				r = _v28;
				continue maxWithDefault;
			}
		}
	});
var _elm_lang$core$Dict$NBlack = {ctor: 'NBlack'};
var _elm_lang$core$Dict$BBlack = {ctor: 'BBlack'};
var _elm_lang$core$Dict$Black = {ctor: 'Black'};
var _elm_lang$core$Dict$blackish = function (t) {
	var _p19 = t;
	if (_p19.ctor === 'RBNode_elm_builtin') {
		var _p20 = _p19._0;
		return _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$Black) || _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$BBlack);
	} else {
		return true;
	}
};
var _elm_lang$core$Dict$Red = {ctor: 'Red'};
var _elm_lang$core$Dict$moreBlack = function (color) {
	var _p21 = color;
	switch (_p21.ctor) {
		case 'Black':
			return _elm_lang$core$Dict$BBlack;
		case 'Red':
			return _elm_lang$core$Dict$Black;
		case 'NBlack':
			return _elm_lang$core$Dict$Red;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a double black node more black!');
	}
};
var _elm_lang$core$Dict$lessBlack = function (color) {
	var _p22 = color;
	switch (_p22.ctor) {
		case 'BBlack':
			return _elm_lang$core$Dict$Black;
		case 'Black':
			return _elm_lang$core$Dict$Red;
		case 'Red':
			return _elm_lang$core$Dict$NBlack;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a negative black node less black!');
	}
};
var _elm_lang$core$Dict$LBBlack = {ctor: 'LBBlack'};
var _elm_lang$core$Dict$LBlack = {ctor: 'LBlack'};
var _elm_lang$core$Dict$RBEmpty_elm_builtin = function (a) {
	return {ctor: 'RBEmpty_elm_builtin', _0: a};
};
var _elm_lang$core$Dict$empty = _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
var _elm_lang$core$Dict$isEmpty = function (dict) {
	return _elm_lang$core$Native_Utils.eq(dict, _elm_lang$core$Dict$empty);
};
var _elm_lang$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {ctor: 'RBNode_elm_builtin', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _elm_lang$core$Dict$ensureBlackRoot = function (dict) {
	var _p23 = dict;
	if ((_p23.ctor === 'RBNode_elm_builtin') && (_p23._0.ctor === 'Red')) {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p23._1, _p23._2, _p23._3, _p23._4);
	} else {
		return dict;
	}
};
var _elm_lang$core$Dict$lessBlackTree = function (dict) {
	var _p24 = dict;
	if (_p24.ctor === 'RBNode_elm_builtin') {
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$lessBlack(_p24._0),
			_p24._1,
			_p24._2,
			_p24._3,
			_p24._4);
	} else {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	}
};
var _elm_lang$core$Dict$balancedTree = function (col) {
	return function (xk) {
		return function (xv) {
			return function (yk) {
				return function (yv) {
					return function (zk) {
						return function (zv) {
							return function (a) {
								return function (b) {
									return function (c) {
										return function (d) {
											return A5(
												_elm_lang$core$Dict$RBNode_elm_builtin,
												_elm_lang$core$Dict$lessBlack(col),
												yk,
												yv,
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, xk, xv, a, b),
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, zk, zv, c, d));
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$core$Dict$blacken = function (t) {
	var _p25 = t;
	if (_p25.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p25._1, _p25._2, _p25._3, _p25._4);
	}
};
var _elm_lang$core$Dict$redden = function (t) {
	var _p26 = t;
	if (_p26.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Native_Debug.crash('can\'t make a Leaf red');
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, _p26._1, _p26._2, _p26._3, _p26._4);
	}
};
var _elm_lang$core$Dict$balanceHelp = function (tree) {
	var _p27 = tree;
	_v36_6:
	do {
		_v36_5:
		do {
			_v36_4:
			do {
				_v36_3:
				do {
					_v36_2:
					do {
						_v36_1:
						do {
							_v36_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v36_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v36_3;
																		} else {
																			break _v36_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v36_4;
																	} else {
																		break _v36_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	break _v36_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v36_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															} else {
																break _v36_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v36_5;
															} else {
																break _v36_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	break _v36_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v36_4;
															} else {
																break _v36_6;
															}
														default:
															break _v36_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v36_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v36_1;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v36_5;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v36_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v36_3;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v36_4;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										} else {
											break _v36_6;
										}
									}
								} else {
									break _v36_6;
								}
							} while(false);
							return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._3._1)(_p27._3._3._2)(_p27._3._1)(_p27._3._2)(_p27._1)(_p27._2)(_p27._3._3._3)(_p27._3._3._4)(_p27._3._4)(_p27._4);
						} while(false);
						return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._1)(_p27._3._2)(_p27._3._4._1)(_p27._3._4._2)(_p27._1)(_p27._2)(_p27._3._3)(_p27._3._4._3)(_p27._3._4._4)(_p27._4);
					} while(false);
					return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._3._1)(_p27._4._3._2)(_p27._4._1)(_p27._4._2)(_p27._3)(_p27._4._3._3)(_p27._4._3._4)(_p27._4._4);
				} while(false);
				return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._1)(_p27._4._2)(_p27._4._4._1)(_p27._4._4._2)(_p27._3)(_p27._4._3)(_p27._4._4._3)(_p27._4._4._4);
			} while(false);
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_elm_lang$core$Dict$Black,
				_p27._4._3._1,
				_p27._4._3._2,
				A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3, _p27._4._3._3),
				A5(
					_elm_lang$core$Dict$balance,
					_elm_lang$core$Dict$Black,
					_p27._4._1,
					_p27._4._2,
					_p27._4._3._4,
					_elm_lang$core$Dict$redden(_p27._4._4)));
		} while(false);
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$Black,
			_p27._3._4._1,
			_p27._3._4._2,
			A5(
				_elm_lang$core$Dict$balance,
				_elm_lang$core$Dict$Black,
				_p27._3._1,
				_p27._3._2,
				_elm_lang$core$Dict$redden(_p27._3._3),
				_p27._3._4._3),
			A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3._4._4, _p27._4));
	} while(false);
	return tree;
};
var _elm_lang$core$Dict$balance = F5(
	function (c, k, v, l, r) {
		var tree = A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
		return _elm_lang$core$Dict$blackish(tree) ? _elm_lang$core$Dict$balanceHelp(tree) : tree;
	});
var _elm_lang$core$Dict$bubble = F5(
	function (c, k, v, l, r) {
		return (_elm_lang$core$Dict$isBBlack(l) || _elm_lang$core$Dict$isBBlack(r)) ? A5(
			_elm_lang$core$Dict$balance,
			_elm_lang$core$Dict$moreBlack(c),
			k,
			v,
			_elm_lang$core$Dict$lessBlackTree(l),
			_elm_lang$core$Dict$lessBlackTree(r)) : A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
	});
var _elm_lang$core$Dict$removeMax = F5(
	function (c, k, v, l, r) {
		var _p28 = r;
		if (_p28.ctor === 'RBEmpty_elm_builtin') {
			return A3(_elm_lang$core$Dict$rem, c, l, r);
		} else {
			return A5(
				_elm_lang$core$Dict$bubble,
				c,
				k,
				v,
				l,
				A5(_elm_lang$core$Dict$removeMax, _p28._0, _p28._1, _p28._2, _p28._3, _p28._4));
		}
	});
var _elm_lang$core$Dict$rem = F3(
	function (color, left, right) {
		var _p29 = {ctor: '_Tuple2', _0: left, _1: right};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = color;
				switch (_p30.ctor) {
					case 'Red':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
					case 'Black':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBBlack);
					default:
						return _elm_lang$core$Native_Debug.crash('cannot have bblack or nblack nodes at this point');
				}
			} else {
				var _p33 = _p29._1._0;
				var _p32 = _p29._0._0;
				var _p31 = {ctor: '_Tuple3', _0: color, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						color,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: color, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						color,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var newLeft = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, color, k, v, newLeft, right);
			}
		}
	});
var _elm_lang$core$Dict$map = F2(
	function (f, dict) {
		var _p41 = dict;
		if (_p41.ctor === 'RBEmpty_elm_builtin') {
			return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
		} else {
			var _p42 = _p41._1;
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_p41._0,
				_p42,
				A2(f, _p42, _p41._2),
				A2(_elm_lang$core$Dict$map, f, _p41._3),
				A2(_elm_lang$core$Dict$map, f, _p41._4));
		}
	});
var _elm_lang$core$Dict$Same = {ctor: 'Same'};
var _elm_lang$core$Dict$Remove = {ctor: 'Remove'};
var _elm_lang$core$Dict$Insert = {ctor: 'Insert'};
var _elm_lang$core$Dict$update = F3(
	function (k, alter, dict) {
		var up = function (dict) {
			var _p43 = dict;
			if (_p43.ctor === 'RBEmpty_elm_builtin') {
				var _p44 = alter(_elm_lang$core$Maybe$Nothing);
				if (_p44.ctor === 'Nothing') {
					return {ctor: '_Tuple2', _0: _elm_lang$core$Dict$Same, _1: _elm_lang$core$Dict$empty};
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Dict$Insert,
						_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, k, _p44._0, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty)
					};
				}
			} else {
				var _p55 = _p43._2;
				var _p54 = _p43._4;
				var _p53 = _p43._3;
				var _p52 = _p43._1;
				var _p51 = _p43._0;
				var _p45 = A2(_elm_lang$core$Basics$compare, k, _p52);
				switch (_p45.ctor) {
					case 'EQ':
						var _p46 = alter(
							_elm_lang$core$Maybe$Just(_p55));
						if (_p46.ctor === 'Nothing') {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Remove,
								_1: A3(_elm_lang$core$Dict$rem, _p51, _p53, _p54)
							};
						} else {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Same,
								_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p46._0, _p53, _p54)
							};
						}
					case 'LT':
						var _p47 = up(_p53);
						var flag = _p47._0;
						var newLeft = _p47._1;
						var _p48 = flag;
						switch (_p48.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, newLeft, _p54)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, newLeft, _p54)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, newLeft, _p54)
								};
						}
					default:
						var _p49 = up(_p54);
						var flag = _p49._0;
						var newRight = _p49._1;
						var _p50 = flag;
						switch (_p50.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, _p53, newRight)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, _p53, newRight)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, _p53, newRight)
								};
						}
				}
			}
		};
		var _p56 = up(dict);
		var flag = _p56._0;
		var updatedDict = _p56._1;
		var _p57 = flag;
		switch (_p57.ctor) {
			case 'Same':
				return updatedDict;
			case 'Insert':
				return _elm_lang$core$Dict$ensureBlackRoot(updatedDict);
			default:
				return _elm_lang$core$Dict$blacken(updatedDict);
		}
	});
var _elm_lang$core$Dict$insert = F3(
	function (key, value, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(
				_elm_lang$core$Maybe$Just(value)),
			dict);
	});
var _elm_lang$core$Dict$singleton = F2(
	function (key, value) {
		return A3(_elm_lang$core$Dict$insert, key, value, _elm_lang$core$Dict$empty);
	});
var _elm_lang$core$Dict$union = F2(
	function (t1, t2) {
		return A3(_elm_lang$core$Dict$foldl, _elm_lang$core$Dict$insert, t2, t1);
	});
var _elm_lang$core$Dict$filter = F2(
	function (predicate, dictionary) {
		var add = F3(
			function (key, value, dict) {
				return A2(predicate, key, value) ? A3(_elm_lang$core$Dict$insert, key, value, dict) : dict;
			});
		return A3(_elm_lang$core$Dict$foldl, add, _elm_lang$core$Dict$empty, dictionary);
	});
var _elm_lang$core$Dict$intersect = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Dict$filter,
			F2(
				function (k, _p58) {
					return A2(_elm_lang$core$Dict$member, k, t2);
				}),
			t1);
	});
var _elm_lang$core$Dict$partition = F2(
	function (predicate, dict) {
		var add = F3(
			function (key, value, _p59) {
				var _p60 = _p59;
				var _p62 = _p60._1;
				var _p61 = _p60._0;
				return A2(predicate, key, value) ? {
					ctor: '_Tuple2',
					_0: A3(_elm_lang$core$Dict$insert, key, value, _p61),
					_1: _p62
				} : {
					ctor: '_Tuple2',
					_0: _p61,
					_1: A3(_elm_lang$core$Dict$insert, key, value, _p62)
				};
			});
		return A3(
			_elm_lang$core$Dict$foldl,
			add,
			{ctor: '_Tuple2', _0: _elm_lang$core$Dict$empty, _1: _elm_lang$core$Dict$empty},
			dict);
	});
var _elm_lang$core$Dict$fromList = function (assocs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p63, dict) {
				var _p64 = _p63;
				return A3(_elm_lang$core$Dict$insert, _p64._0, _p64._1, dict);
			}),
		_elm_lang$core$Dict$empty,
		assocs);
};
var _elm_lang$core$Dict$remove = F2(
	function (key, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(_elm_lang$core$Maybe$Nothing),
			dict);
	});
var _elm_lang$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2(_elm_lang$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});

var _elm_lang$core$Json_Decode$null = _elm_lang$core$Native_Json.decodeNull;
var _elm_lang$core$Json_Decode$value = _elm_lang$core$Native_Json.decodePrimitive('value');
var _elm_lang$core$Json_Decode$andThen = _elm_lang$core$Native_Json.andThen;
var _elm_lang$core$Json_Decode$fail = _elm_lang$core$Native_Json.fail;
var _elm_lang$core$Json_Decode$succeed = _elm_lang$core$Native_Json.succeed;
var _elm_lang$core$Json_Decode$lazy = function (thunk) {
	return A2(
		_elm_lang$core$Json_Decode$andThen,
		thunk,
		_elm_lang$core$Json_Decode$succeed(
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Json_Decode$decodeValue = _elm_lang$core$Native_Json.run;
var _elm_lang$core$Json_Decode$decodeString = _elm_lang$core$Native_Json.runOnString;
var _elm_lang$core$Json_Decode$map8 = _elm_lang$core$Native_Json.map8;
var _elm_lang$core$Json_Decode$map7 = _elm_lang$core$Native_Json.map7;
var _elm_lang$core$Json_Decode$map6 = _elm_lang$core$Native_Json.map6;
var _elm_lang$core$Json_Decode$map5 = _elm_lang$core$Native_Json.map5;
var _elm_lang$core$Json_Decode$map4 = _elm_lang$core$Native_Json.map4;
var _elm_lang$core$Json_Decode$map3 = _elm_lang$core$Native_Json.map3;
var _elm_lang$core$Json_Decode$map2 = _elm_lang$core$Native_Json.map2;
var _elm_lang$core$Json_Decode$map = _elm_lang$core$Native_Json.map1;
var _elm_lang$core$Json_Decode$oneOf = _elm_lang$core$Native_Json.oneOf;
var _elm_lang$core$Json_Decode$maybe = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'maybe', decoder);
};
var _elm_lang$core$Json_Decode$index = _elm_lang$core$Native_Json.decodeIndex;
var _elm_lang$core$Json_Decode$field = _elm_lang$core$Native_Json.decodeField;
var _elm_lang$core$Json_Decode$at = F2(
	function (fields, decoder) {
		return A3(_elm_lang$core$List$foldr, _elm_lang$core$Json_Decode$field, decoder, fields);
	});
var _elm_lang$core$Json_Decode$keyValuePairs = _elm_lang$core$Native_Json.decodeKeyValuePairs;
var _elm_lang$core$Json_Decode$dict = function (decoder) {
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$Dict$fromList,
		_elm_lang$core$Json_Decode$keyValuePairs(decoder));
};
var _elm_lang$core$Json_Decode$array = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'array', decoder);
};
var _elm_lang$core$Json_Decode$list = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'list', decoder);
};
var _elm_lang$core$Json_Decode$nullable = function (decoder) {
	return _elm_lang$core$Json_Decode$oneOf(
		{
			ctor: '::',
			_0: _elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, decoder),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$core$Json_Decode$float = _elm_lang$core$Native_Json.decodePrimitive('float');
var _elm_lang$core$Json_Decode$int = _elm_lang$core$Native_Json.decodePrimitive('int');
var _elm_lang$core$Json_Decode$bool = _elm_lang$core$Native_Json.decodePrimitive('bool');
var _elm_lang$core$Json_Decode$string = _elm_lang$core$Native_Json.decodePrimitive('string');
var _elm_lang$core$Json_Decode$Decoder = {ctor: 'Decoder'};

//import Native.Utils //

var _elm_lang$core$Native_Scheduler = function() {

var MAX_STEPS = 10000;


// TASKS

function succeed(value)
{
	return {
		ctor: '_Task_succeed',
		value: value
	};
}

function fail(error)
{
	return {
		ctor: '_Task_fail',
		value: error
	};
}

function nativeBinding(callback)
{
	return {
		ctor: '_Task_nativeBinding',
		callback: callback,
		cancel: null
	};
}

function andThen(callback, task)
{
	return {
		ctor: '_Task_andThen',
		callback: callback,
		task: task
	};
}

function onError(callback, task)
{
	return {
		ctor: '_Task_onError',
		callback: callback,
		task: task
	};
}

function receive(callback)
{
	return {
		ctor: '_Task_receive',
		callback: callback
	};
}


// PROCESSES

function rawSpawn(task)
{
	var process = {
		ctor: '_Process',
		id: _elm_lang$core$Native_Utils.guid(),
		root: task,
		stack: null,
		mailbox: []
	};

	enqueue(process);

	return process;
}

function spawn(task)
{
	return nativeBinding(function(callback) {
		var process = rawSpawn(task);
		callback(succeed(process));
	});
}

function rawSend(process, msg)
{
	process.mailbox.push(msg);
	enqueue(process);
}

function send(process, msg)
{
	return nativeBinding(function(callback) {
		rawSend(process, msg);
		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function kill(process)
{
	return nativeBinding(function(callback) {
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding' && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sleep(time)
{
	return nativeBinding(function(callback) {
		var id = setTimeout(function() {
			callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}


// STEP PROCESSES

function step(numSteps, process)
{
	while (numSteps < MAX_STEPS)
	{
		var ctor = process.root.ctor;

		if (ctor === '_Task_succeed')
		{
			while (process.stack && process.stack.ctor === '_Task_onError')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_fail')
		{
			while (process.stack && process.stack.ctor === '_Task_andThen')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_andThen')
		{
			process.stack = {
				ctor: '_Task_andThen',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_onError')
		{
			process.stack = {
				ctor: '_Task_onError',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_nativeBinding')
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				enqueue(process);
			});

			break;
		}

		if (ctor === '_Task_receive')
		{
			var mailbox = process.mailbox;
			if (mailbox.length === 0)
			{
				break;
			}

			process.root = process.root.callback(mailbox.shift());
			++numSteps;
			continue;
		}

		throw new Error(ctor);
	}

	if (numSteps < MAX_STEPS)
	{
		return numSteps + 1;
	}
	enqueue(process);

	return numSteps;
}


// WORK QUEUE

var working = false;
var workQueue = [];

function enqueue(process)
{
	workQueue.push(process);

	if (!working)
	{
		setTimeout(work, 0);
		working = true;
	}
}

function work()
{
	var numSteps = 0;
	var process;
	while (numSteps < MAX_STEPS && (process = workQueue.shift()))
	{
		if (process.root)
		{
			numSteps = step(numSteps, process);
		}
	}
	if (!process)
	{
		working = false;
		return;
	}
	setTimeout(work, 0);
}


return {
	succeed: succeed,
	fail: fail,
	nativeBinding: nativeBinding,
	andThen: F2(andThen),
	onError: F2(onError),
	receive: receive,

	spawn: spawn,
	kill: kill,
	sleep: sleep,
	send: F2(send),

	rawSpawn: rawSpawn,
	rawSend: rawSend
};

}();
//import //

var _elm_lang$core$Native_Platform = function() {


// PROGRAMS

function program(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flags !== 'undefined')
				{
					throw new Error(
						'The `' + moduleName + '` module does not need flags.\n'
						+ 'Call ' + moduleName + '.worker() with no arguments and you should be all set!'
					);
				}

				return initialize(
					impl.init,
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function programWithFlags(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flagDecoder === 'undefined')
				{
					throw new Error(
						'Are you trying to sneak a Never value into Elm? Trickster!\n'
						+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
						+ 'Use `program` instead if you do not want flags.'
					);
				}

				var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
				if (result.ctor === 'Err')
				{
					throw new Error(
						moduleName + '.worker(...) was called with an unexpected argument.\n'
						+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
						+ result._0
					);
				}

				return initialize(
					impl.init(result._0),
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function renderer(enqueue, _)
{
	return function(_) {};
}


// HTML TO PROGRAM

function htmlToProgram(vnode)
{
	var emptyBag = batch(_elm_lang$core$Native_List.Nil);
	var noChange = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		emptyBag
	);

	return _elm_lang$virtual_dom$VirtualDom$program({
		init: noChange,
		view: function(model) { return main; },
		update: F2(function(msg, model) { return noChange; }),
		subscriptions: function (model) { return emptyBag; }
	});
}


// INITIALIZE A PROGRAM

function initialize(init, update, subscriptions, renderer)
{
	// ambient state
	var managers = {};
	var updateView;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var model = init._0;
		updateView = renderer(enqueue, model);
		var cmds = init._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			updateView(model);
			var cmds = results._1;
			var subs = subscriptions(model);
			dispatchEffects(managers, cmds, subs);
			callback(_elm_lang$core$Native_Scheduler.succeed(model));
		});
	}

	var mainProcess = spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		_elm_lang$core$Native_Scheduler.rawSend(mainProcess, msg);
	}

	var ports = setupEffects(managers, enqueue);

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var effectManagers = {};

function setupEffects(managers, callback)
{
	var ports;

	// setup all necessary effect managers
	for (var key in effectManagers)
	{
		var manager = effectManagers[key];

		if (manager.isForeign)
		{
			ports = ports || {};
			ports[key] = manager.tag === 'cmd'
				? setupOutgoingPort(key)
				: setupIncomingPort(key, callback);
		}

		managers[key] = makeManager(manager, callback);
	}

	return ports;
}

function makeManager(info, callback)
{
	var router = {
		main: callback,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.ctor === 'self')
		{
			return A3(onSelfMsg, router, msg._0, state);
		}

		var fx = msg._0;
		switch (tag)
		{
			case 'cmd':
				return A3(onEffects, router, fx.cmds, state);

			case 'sub':
				return A3(onEffects, router, fx.subs, state);

			case 'fx':
				return A4(onEffects, router, fx.cmds, fx.subs, state);
		}
	}

	var process = spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

function sendToApp(router, msg)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		router.main(msg);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sendToSelf(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.self, {
		ctor: 'self',
		_0: msg
	});
}


// HELPER for STATEFUL LOOPS

function spawnLoop(init, onMessage)
{
	var andThen = _elm_lang$core$Native_Scheduler.andThen;

	function loop(state)
	{
		var handleMsg = _elm_lang$core$Native_Scheduler.receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(andThen, loop, handleMsg);
	}

	var task = A2(andThen, loop, init);

	return _elm_lang$core$Native_Scheduler.rawSpawn(task);
}


// BAGS

function leaf(home)
{
	return function(value)
	{
		return {
			type: 'leaf',
			home: home,
			value: value
		};
	};
}

function batch(list)
{
	return {
		type: 'node',
		branches: list
	};
}

function map(tagger, bag)
{
	return {
		type: 'map',
		tagger: tagger,
		tree: bag
	}
}


// PIPE BAGS INTO EFFECT MANAGERS

function dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects(true, cmdBag, effectsDict, null);
	gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		var fx = home in effectsDict
			? effectsDict[home]
			: {
				cmds: _elm_lang$core$Native_List.Nil,
				subs: _elm_lang$core$Native_List.Nil
			};

		_elm_lang$core$Native_Scheduler.rawSend(managers[home], { ctor: 'fx', _0: fx });
	}
}

function gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(isCmd, list._0, effectsDict, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		var temp = taggers;
		while (temp)
		{
			x = temp.tagger(x);
			temp = temp.rest;
		}
		return x;
	}

	var map = isCmd
		? effectManagers[home].cmdMap
		: effectManagers[home].subMap;

	return A2(map, applyTaggers, value)
}

function insert(isCmd, newEffect, effects)
{
	effects = effects || {
		cmds: _elm_lang$core$Native_List.Nil,
		subs: _elm_lang$core$Native_List.Nil
	};
	if (isCmd)
	{
		effects.cmds = _elm_lang$core$Native_List.Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = _elm_lang$core$Native_List.Cons(newEffect, effects.subs);
	return effects;
}


// PORTS

function checkPortName(name)
{
	if (name in effectManagers)
	{
		throw new Error('There can only be one port named `' + name + '`, but your program has multiple.');
	}
}


// OUTGOING PORTS

function outgoingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'cmd',
		cmdMap: outgoingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var outgoingPortMap = F2(function cmdMap(tagger, value) {
	return value;
});

function setupOutgoingPort(name)
{
	var subs = [];
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, cmdList, state)
	{
		while (cmdList.ctor !== '[]')
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = converter(cmdList._0);
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
			cmdList = cmdList._1;
		}
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}


// INCOMING PORTS

function incomingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'sub',
		subMap: incomingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var incomingPortMap = F2(function subMap(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});

function setupIncomingPort(name, callback)
{
	var sentBeforeInit = [];
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;
	var currentOnEffects = preInitOnEffects;
	var currentSend = preInitSend;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function preInitOnEffects(router, subList, state)
	{
		var postInitResult = postInitOnEffects(router, subList, state);

		for(var i = 0; i < sentBeforeInit.length; i++)
		{
			postInitSend(sentBeforeInit[i]);
		}

		sentBeforeInit = null; // to release objects held in queue
		currentSend = postInitSend;
		currentOnEffects = postInitOnEffects;
		return postInitResult;
	}

	function postInitOnEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	function onEffects(router, subList, state)
	{
		return currentOnEffects(router, subList, state);
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function preInitSend(value)
	{
		sentBeforeInit.push(value);
	}

	function postInitSend(value)
	{
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			callback(temp._0(value));
			temp = temp._1;
		}
	}

	function send(incomingValue)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, incomingValue);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through port `' + name + '`:\n' + result._0);
		}

		currentSend(result._0);
	}

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,

	htmlToProgram: htmlToProgram,
	program: program,
	programWithFlags: programWithFlags,
	initialize: initialize,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
};

}();

var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Cmd_ops = _elm_lang$core$Platform_Cmd_ops || {};
_elm_lang$core$Platform_Cmd_ops['!'] = F2(
	function (model, commands) {
		return {
			ctor: '_Tuple2',
			_0: model,
			_1: _elm_lang$core$Platform_Cmd$batch(commands)
		};
	});
var _elm_lang$core$Platform_Cmd$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Cmd$Cmd = {ctor: 'Cmd'};

var _elm_lang$core$Platform_Sub$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Sub$none = _elm_lang$core$Platform_Sub$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$programWithFlags = _elm_lang$core$Native_Platform.programWithFlags;
var _elm_lang$core$Platform$program = _elm_lang$core$Native_Platform.program;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _elm_lang$core$Task$onError = _elm_lang$core$Native_Scheduler.onError;
var _elm_lang$core$Task$andThen = _elm_lang$core$Native_Scheduler.andThen;
var _elm_lang$core$Task$spawnCmd = F2(
	function (router, _p0) {
		var _p1 = _p0;
		return _elm_lang$core$Native_Scheduler.spawn(
			A2(
				_elm_lang$core$Task$andThen,
				_elm_lang$core$Platform$sendToApp(router),
				_p1._0));
	});
var _elm_lang$core$Task$fail = _elm_lang$core$Native_Scheduler.fail;
var _elm_lang$core$Task$mapError = F2(
	function (convert, task) {
		return A2(
			_elm_lang$core$Task$onError,
			function (_p2) {
				return _elm_lang$core$Task$fail(
					convert(_p2));
			},
			task);
	});
var _elm_lang$core$Task$succeed = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return _elm_lang$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var _elm_lang$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return _elm_lang$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map3 = F4(
	function (func, taskA, taskB, taskC) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return _elm_lang$core$Task$succeed(
									A3(func, a, b, c));
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map4 = F5(
	function (func, taskA, taskB, taskC, taskD) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									function (d) {
										return _elm_lang$core$Task$succeed(
											A4(func, a, b, c, d));
									},
									taskD);
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$map5 = F6(
	function (func, taskA, taskB, taskC, taskD, taskE) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (a) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (b) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (c) {
								return A2(
									_elm_lang$core$Task$andThen,
									function (d) {
										return A2(
											_elm_lang$core$Task$andThen,
											function (e) {
												return _elm_lang$core$Task$succeed(
													A5(func, a, b, c, d, e));
											},
											taskE);
									},
									taskD);
							},
							taskC);
					},
					taskB);
			},
			taskA);
	});
var _elm_lang$core$Task$sequence = function (tasks) {
	var _p3 = tasks;
	if (_p3.ctor === '[]') {
		return _elm_lang$core$Task$succeed(
			{ctor: '[]'});
	} else {
		return A3(
			_elm_lang$core$Task$map2,
			F2(
				function (x, y) {
					return {ctor: '::', _0: x, _1: y};
				}),
			_p3._0,
			_elm_lang$core$Task$sequence(_p3._1));
	}
};
var _elm_lang$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			_elm_lang$core$Task$map,
			function (_p4) {
				return {ctor: '_Tuple0'};
			},
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					_elm_lang$core$Task$spawnCmd(router),
					commands)));
	});
var _elm_lang$core$Task$init = _elm_lang$core$Task$succeed(
	{ctor: '_Tuple0'});
var _elm_lang$core$Task$onSelfMsg = F3(
	function (_p7, _p6, _p5) {
		return _elm_lang$core$Task$succeed(
			{ctor: '_Tuple0'});
	});
var _elm_lang$core$Task$command = _elm_lang$core$Native_Platform.leaf('Task');
var _elm_lang$core$Task$Perform = function (a) {
	return {ctor: 'Perform', _0: a};
};
var _elm_lang$core$Task$perform = F2(
	function (toMessage, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$Perform(
				A2(_elm_lang$core$Task$map, toMessage, task)));
	});
var _elm_lang$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return _elm_lang$core$Task$command(
			_elm_lang$core$Task$Perform(
				A2(
					_elm_lang$core$Task$onError,
					function (_p8) {
						return _elm_lang$core$Task$succeed(
							resultToMessage(
								_elm_lang$core$Result$Err(_p8)));
					},
					A2(
						_elm_lang$core$Task$andThen,
						function (_p9) {
							return _elm_lang$core$Task$succeed(
								resultToMessage(
									_elm_lang$core$Result$Ok(_p9)));
						},
						task))));
	});
var _elm_lang$core$Task$cmdMap = F2(
	function (tagger, _p10) {
		var _p11 = _p10;
		return _elm_lang$core$Task$Perform(
			A2(_elm_lang$core$Task$map, tagger, _p11._0));
	});
_elm_lang$core$Native_Platform.effectManagers['Task'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Task$init, onEffects: _elm_lang$core$Task$onEffects, onSelfMsg: _elm_lang$core$Task$onSelfMsg, tag: 'cmd', cmdMap: _elm_lang$core$Task$cmdMap};

var _elm_lang$core$Tuple$mapSecond = F2(
	function (func, _p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: _p1._0,
			_1: func(_p1._1)
		};
	});
var _elm_lang$core$Tuple$mapFirst = F2(
	function (func, _p2) {
		var _p3 = _p2;
		return {
			ctor: '_Tuple2',
			_0: func(_p3._0),
			_1: _p3._1
		};
	});
var _elm_lang$core$Tuple$second = function (_p4) {
	var _p5 = _p4;
	return _p5._1;
};
var _elm_lang$core$Tuple$first = function (_p6) {
	var _p7 = _p6;
	return _p7._0;
};

//import Native.Scheduler //

var _elm_lang$core$Native_Time = function() {

var now = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
{
	callback(_elm_lang$core$Native_Scheduler.succeed(Date.now()));
});

function setInterval_(interval, task)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var id = setInterval(function() {
			_elm_lang$core$Native_Scheduler.rawSpawn(task);
		}, interval);

		return function() { clearInterval(id); };
	});
}

return {
	now: now,
	setInterval_: F2(setInterval_)
};

}();
var _elm_lang$core$Time$setInterval = _elm_lang$core$Native_Time.setInterval_;
var _elm_lang$core$Time$spawnHelp = F3(
	function (router, intervals, processes) {
		var _p0 = intervals;
		if (_p0.ctor === '[]') {
			return _elm_lang$core$Task$succeed(processes);
		} else {
			var _p1 = _p0._0;
			var spawnRest = function (id) {
				return A3(
					_elm_lang$core$Time$spawnHelp,
					router,
					_p0._1,
					A3(_elm_lang$core$Dict$insert, _p1, id, processes));
			};
			var spawnTimer = _elm_lang$core$Native_Scheduler.spawn(
				A2(
					_elm_lang$core$Time$setInterval,
					_p1,
					A2(_elm_lang$core$Platform$sendToSelf, router, _p1)));
			return A2(_elm_lang$core$Task$andThen, spawnRest, spawnTimer);
		}
	});
var _elm_lang$core$Time$addMySub = F2(
	function (_p2, state) {
		var _p3 = _p2;
		var _p6 = _p3._1;
		var _p5 = _p3._0;
		var _p4 = A2(_elm_lang$core$Dict$get, _p5, state);
		if (_p4.ctor === 'Nothing') {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				{
					ctor: '::',
					_0: _p6,
					_1: {ctor: '[]'}
				},
				state);
		} else {
			return A3(
				_elm_lang$core$Dict$insert,
				_p5,
				{ctor: '::', _0: _p6, _1: _p4._0},
				state);
		}
	});
var _elm_lang$core$Time$inMilliseconds = function (t) {
	return t;
};
var _elm_lang$core$Time$millisecond = 1;
var _elm_lang$core$Time$second = 1000 * _elm_lang$core$Time$millisecond;
var _elm_lang$core$Time$minute = 60 * _elm_lang$core$Time$second;
var _elm_lang$core$Time$hour = 60 * _elm_lang$core$Time$minute;
var _elm_lang$core$Time$inHours = function (t) {
	return t / _elm_lang$core$Time$hour;
};
var _elm_lang$core$Time$inMinutes = function (t) {
	return t / _elm_lang$core$Time$minute;
};
var _elm_lang$core$Time$inSeconds = function (t) {
	return t / _elm_lang$core$Time$second;
};
var _elm_lang$core$Time$now = _elm_lang$core$Native_Time.now;
var _elm_lang$core$Time$onSelfMsg = F3(
	function (router, interval, state) {
		var _p7 = A2(_elm_lang$core$Dict$get, interval, state.taggers);
		if (_p7.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var tellTaggers = function (time) {
				return _elm_lang$core$Task$sequence(
					A2(
						_elm_lang$core$List$map,
						function (tagger) {
							return A2(
								_elm_lang$core$Platform$sendToApp,
								router,
								tagger(time));
						},
						_p7._0));
			};
			return A2(
				_elm_lang$core$Task$andThen,
				function (_p8) {
					return _elm_lang$core$Task$succeed(state);
				},
				A2(_elm_lang$core$Task$andThen, tellTaggers, _elm_lang$core$Time$now));
		}
	});
var _elm_lang$core$Time$subscription = _elm_lang$core$Native_Platform.leaf('Time');
var _elm_lang$core$Time$State = F2(
	function (a, b) {
		return {taggers: a, processes: b};
	});
var _elm_lang$core$Time$init = _elm_lang$core$Task$succeed(
	A2(_elm_lang$core$Time$State, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty));
var _elm_lang$core$Time$onEffects = F3(
	function (router, subs, _p9) {
		var _p10 = _p9;
		var rightStep = F3(
			function (_p12, id, _p11) {
				var _p13 = _p11;
				return {
					ctor: '_Tuple3',
					_0: _p13._0,
					_1: _p13._1,
					_2: A2(
						_elm_lang$core$Task$andThen,
						function (_p14) {
							return _p13._2;
						},
						_elm_lang$core$Native_Scheduler.kill(id))
				};
			});
		var bothStep = F4(
			function (interval, taggers, id, _p15) {
				var _p16 = _p15;
				return {
					ctor: '_Tuple3',
					_0: _p16._0,
					_1: A3(_elm_lang$core$Dict$insert, interval, id, _p16._1),
					_2: _p16._2
				};
			});
		var leftStep = F3(
			function (interval, taggers, _p17) {
				var _p18 = _p17;
				return {
					ctor: '_Tuple3',
					_0: {ctor: '::', _0: interval, _1: _p18._0},
					_1: _p18._1,
					_2: _p18._2
				};
			});
		var newTaggers = A3(_elm_lang$core$List$foldl, _elm_lang$core$Time$addMySub, _elm_lang$core$Dict$empty, subs);
		var _p19 = A6(
			_elm_lang$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			newTaggers,
			_p10.processes,
			{
				ctor: '_Tuple3',
				_0: {ctor: '[]'},
				_1: _elm_lang$core$Dict$empty,
				_2: _elm_lang$core$Task$succeed(
					{ctor: '_Tuple0'})
			});
		var spawnList = _p19._0;
		var existingDict = _p19._1;
		var killTask = _p19._2;
		return A2(
			_elm_lang$core$Task$andThen,
			function (newProcesses) {
				return _elm_lang$core$Task$succeed(
					A2(_elm_lang$core$Time$State, newTaggers, newProcesses));
			},
			A2(
				_elm_lang$core$Task$andThen,
				function (_p20) {
					return A3(_elm_lang$core$Time$spawnHelp, router, spawnList, existingDict);
				},
				killTask));
	});
var _elm_lang$core$Time$Every = F2(
	function (a, b) {
		return {ctor: 'Every', _0: a, _1: b};
	});
var _elm_lang$core$Time$every = F2(
	function (interval, tagger) {
		return _elm_lang$core$Time$subscription(
			A2(_elm_lang$core$Time$Every, interval, tagger));
	});
var _elm_lang$core$Time$subMap = F2(
	function (f, _p21) {
		var _p22 = _p21;
		return A2(
			_elm_lang$core$Time$Every,
			_p22._0,
			function (_p23) {
				return f(
					_p22._1(_p23));
			});
	});
_elm_lang$core$Native_Platform.effectManagers['Time'] = {pkg: 'elm-lang/core', init: _elm_lang$core$Time$init, onEffects: _elm_lang$core$Time$onEffects, onSelfMsg: _elm_lang$core$Time$onSelfMsg, tag: 'sub', subMap: _elm_lang$core$Time$subMap};

var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

var _mgold$elm_random_pcg$Random_Pcg$toJson = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$core$Json_Encode$list(
		{
			ctor: '::',
			_0: _elm_lang$core$Json_Encode$int(_p1._0),
			_1: {
				ctor: '::',
				_0: _elm_lang$core$Json_Encode$int(_p1._1),
				_1: {ctor: '[]'}
			}
		});
};
var _mgold$elm_random_pcg$Random_Pcg$mul32 = F2(
	function (a, b) {
		var bl = b & 65535;
		var bh = 65535 & (b >>> 16);
		var al = a & 65535;
		var ah = 65535 & (a >>> 16);
		return 0 | ((al * bl) + ((((ah * bl) + (al * bh)) << 16) >>> 0));
	});
var _mgold$elm_random_pcg$Random_Pcg$listHelp = F4(
	function (list, n, generate, seed) {
		listHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 1) < 0) {
				return {ctor: '_Tuple2', _0: list, _1: seed};
			} else {
				var _p2 = generate(seed);
				var value = _p2._0;
				var newSeed = _p2._1;
				var _v1 = {ctor: '::', _0: value, _1: list},
					_v2 = n - 1,
					_v3 = generate,
					_v4 = newSeed;
				list = _v1;
				n = _v2;
				generate = _v3;
				seed = _v4;
				continue listHelp;
			}
		}
	});
var _mgold$elm_random_pcg$Random_Pcg$minInt = -2147483648;
var _mgold$elm_random_pcg$Random_Pcg$maxInt = 2147483647;
var _mgold$elm_random_pcg$Random_Pcg$bit27 = 1.34217728e8;
var _mgold$elm_random_pcg$Random_Pcg$bit53 = 9.007199254740992e15;
var _mgold$elm_random_pcg$Random_Pcg$peel = function (_p3) {
	var _p4 = _p3;
	var _p5 = _p4._0;
	var word = (_p5 ^ (_p5 >>> ((_p5 >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var _mgold$elm_random_pcg$Random_Pcg$step = F2(
	function (_p6, seed) {
		var _p7 = _p6;
		return _p7._0(seed);
	});
var _mgold$elm_random_pcg$Random_Pcg$retry = F3(
	function (generator, predicate, seed) {
		retry:
		while (true) {
			var _p8 = A2(_mgold$elm_random_pcg$Random_Pcg$step, generator, seed);
			var candidate = _p8._0;
			var newSeed = _p8._1;
			if (predicate(candidate)) {
				return {ctor: '_Tuple2', _0: candidate, _1: newSeed};
			} else {
				var _v7 = generator,
					_v8 = predicate,
					_v9 = newSeed;
				generator = _v7;
				predicate = _v8;
				seed = _v9;
				continue retry;
			}
		}
	});
var _mgold$elm_random_pcg$Random_Pcg$Generator = function (a) {
	return {ctor: 'Generator', _0: a};
};
var _mgold$elm_random_pcg$Random_Pcg$list = F2(
	function (n, _p9) {
		var _p10 = _p9;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed) {
				return A4(
					_mgold$elm_random_pcg$Random_Pcg$listHelp,
					{ctor: '[]'},
					n,
					_p10._0,
					seed);
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$constant = function (value) {
	return _mgold$elm_random_pcg$Random_Pcg$Generator(
		function (seed) {
			return {ctor: '_Tuple2', _0: value, _1: seed};
		});
};
var _mgold$elm_random_pcg$Random_Pcg$map = F2(
	function (func, _p11) {
		var _p12 = _p11;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var _p13 = _p12._0(seed0);
				var a = _p13._0;
				var seed1 = _p13._1;
				return {
					ctor: '_Tuple2',
					_0: func(a),
					_1: seed1
				};
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$map2 = F3(
	function (func, _p15, _p14) {
		var _p16 = _p15;
		var _p17 = _p14;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var _p18 = _p16._0(seed0);
				var a = _p18._0;
				var seed1 = _p18._1;
				var _p19 = _p17._0(seed1);
				var b = _p19._0;
				var seed2 = _p19._1;
				return {
					ctor: '_Tuple2',
					_0: A2(func, a, b),
					_1: seed2
				};
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$pair = F2(
	function (genA, genB) {
		return A3(
			_mgold$elm_random_pcg$Random_Pcg$map2,
			F2(
				function (v0, v1) {
					return {ctor: '_Tuple2', _0: v0, _1: v1};
				}),
			genA,
			genB);
	});
var _mgold$elm_random_pcg$Random_Pcg$andMap = _mgold$elm_random_pcg$Random_Pcg$map2(
	F2(
		function (x, y) {
			return x(y);
		}));
var _mgold$elm_random_pcg$Random_Pcg$map3 = F4(
	function (func, _p22, _p21, _p20) {
		var _p23 = _p22;
		var _p24 = _p21;
		var _p25 = _p20;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var _p26 = _p23._0(seed0);
				var a = _p26._0;
				var seed1 = _p26._1;
				var _p27 = _p24._0(seed1);
				var b = _p27._0;
				var seed2 = _p27._1;
				var _p28 = _p25._0(seed2);
				var c = _p28._0;
				var seed3 = _p28._1;
				return {
					ctor: '_Tuple2',
					_0: A3(func, a, b, c),
					_1: seed3
				};
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$map4 = F5(
	function (func, _p32, _p31, _p30, _p29) {
		var _p33 = _p32;
		var _p34 = _p31;
		var _p35 = _p30;
		var _p36 = _p29;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var _p37 = _p33._0(seed0);
				var a = _p37._0;
				var seed1 = _p37._1;
				var _p38 = _p34._0(seed1);
				var b = _p38._0;
				var seed2 = _p38._1;
				var _p39 = _p35._0(seed2);
				var c = _p39._0;
				var seed3 = _p39._1;
				var _p40 = _p36._0(seed3);
				var d = _p40._0;
				var seed4 = _p40._1;
				return {
					ctor: '_Tuple2',
					_0: A4(func, a, b, c, d),
					_1: seed4
				};
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$map5 = F6(
	function (func, _p45, _p44, _p43, _p42, _p41) {
		var _p46 = _p45;
		var _p47 = _p44;
		var _p48 = _p43;
		var _p49 = _p42;
		var _p50 = _p41;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var _p51 = _p46._0(seed0);
				var a = _p51._0;
				var seed1 = _p51._1;
				var _p52 = _p47._0(seed1);
				var b = _p52._0;
				var seed2 = _p52._1;
				var _p53 = _p48._0(seed2);
				var c = _p53._0;
				var seed3 = _p53._1;
				var _p54 = _p49._0(seed3);
				var d = _p54._0;
				var seed4 = _p54._1;
				var _p55 = _p50._0(seed4);
				var e = _p55._0;
				var seed5 = _p55._1;
				return {
					ctor: '_Tuple2',
					_0: A5(func, a, b, c, d, e),
					_1: seed5
				};
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$andThen = F2(
	function (callback, _p56) {
		var _p57 = _p56;
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed) {
				var _p58 = _p57._0(seed);
				var result = _p58._0;
				var newSeed = _p58._1;
				var _p59 = callback(result);
				var generateB = _p59._0;
				return generateB(newSeed);
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$maybe = F2(
	function (genBool, genA) {
		return A2(
			_mgold$elm_random_pcg$Random_Pcg$andThen,
			function (b) {
				return b ? A2(_mgold$elm_random_pcg$Random_Pcg$map, _elm_lang$core$Maybe$Just, genA) : _mgold$elm_random_pcg$Random_Pcg$constant(_elm_lang$core$Maybe$Nothing);
			},
			genBool);
	});
var _mgold$elm_random_pcg$Random_Pcg$filter = F2(
	function (predicate, generator) {
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			A2(_mgold$elm_random_pcg$Random_Pcg$retry, generator, predicate));
	});
var _mgold$elm_random_pcg$Random_Pcg$Seed = F2(
	function (a, b) {
		return {ctor: 'Seed', _0: a, _1: b};
	});
var _mgold$elm_random_pcg$Random_Pcg$next = function (_p60) {
	var _p61 = _p60;
	var _p62 = _p61._1;
	return A2(_mgold$elm_random_pcg$Random_Pcg$Seed, ((_p61._0 * 1664525) + _p62) >>> 0, _p62);
};
var _mgold$elm_random_pcg$Random_Pcg$initialSeed = function (x) {
	var _p63 = _mgold$elm_random_pcg$Random_Pcg$next(
		A2(_mgold$elm_random_pcg$Random_Pcg$Seed, 0, 1013904223));
	var state1 = _p63._0;
	var incr = _p63._1;
	var state2 = (state1 + x) >>> 0;
	return _mgold$elm_random_pcg$Random_Pcg$next(
		A2(_mgold$elm_random_pcg$Random_Pcg$Seed, state2, incr));
};
var _mgold$elm_random_pcg$Random_Pcg$generate = F2(
	function (toMsg, generator) {
		return A2(
			_elm_lang$core$Task$perform,
			toMsg,
			A2(
				_elm_lang$core$Task$map,
				function (_p64) {
					return _elm_lang$core$Tuple$first(
						A2(
							_mgold$elm_random_pcg$Random_Pcg$step,
							generator,
							_mgold$elm_random_pcg$Random_Pcg$initialSeed(
								_elm_lang$core$Basics$round(_p64))));
				},
				_elm_lang$core$Time$now));
	});
var _mgold$elm_random_pcg$Random_Pcg$int = F2(
	function (a, b) {
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var _p65 = (_elm_lang$core$Native_Utils.cmp(a, b) < 0) ? {ctor: '_Tuple2', _0: a, _1: b} : {ctor: '_Tuple2', _0: b, _1: a};
				var lo = _p65._0;
				var hi = _p65._1;
				var range = (hi - lo) + 1;
				if (_elm_lang$core$Native_Utils.eq((range - 1) & range, 0)) {
					return {
						ctor: '_Tuple2',
						_0: (((range - 1) & _mgold$elm_random_pcg$Random_Pcg$peel(seed0)) >>> 0) + lo,
						_1: _mgold$elm_random_pcg$Random_Pcg$next(seed0)
					};
				} else {
					var threshhold = A2(_elm_lang$core$Basics$rem, (0 - range) >>> 0, range) >>> 0;
					var accountForBias = function (seed) {
						accountForBias:
						while (true) {
							var seedN = _mgold$elm_random_pcg$Random_Pcg$next(seed);
							var x = _mgold$elm_random_pcg$Random_Pcg$peel(seed);
							if (_elm_lang$core$Native_Utils.cmp(x, threshhold) < 0) {
								var _v28 = seedN;
								seed = _v28;
								continue accountForBias;
							} else {
								return {
									ctor: '_Tuple2',
									_0: A2(_elm_lang$core$Basics$rem, x, range) + lo,
									_1: seedN
								};
							}
						}
					};
					return accountForBias(seed0);
				}
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$bool = A2(
	_mgold$elm_random_pcg$Random_Pcg$map,
	F2(
		function (x, y) {
			return _elm_lang$core$Native_Utils.eq(x, y);
		})(1),
	A2(_mgold$elm_random_pcg$Random_Pcg$int, 0, 1));
var _mgold$elm_random_pcg$Random_Pcg$choice = F2(
	function (x, y) {
		return A2(
			_mgold$elm_random_pcg$Random_Pcg$map,
			function (b) {
				return b ? x : y;
			},
			_mgold$elm_random_pcg$Random_Pcg$bool);
	});
var _mgold$elm_random_pcg$Random_Pcg$oneIn = function (n) {
	return A2(
		_mgold$elm_random_pcg$Random_Pcg$map,
		F2(
			function (x, y) {
				return _elm_lang$core$Native_Utils.eq(x, y);
			})(1),
		A2(_mgold$elm_random_pcg$Random_Pcg$int, 1, n));
};
var _mgold$elm_random_pcg$Random_Pcg$sample = function () {
	var find = F2(
		function (k, ys) {
			find:
			while (true) {
				var _p66 = ys;
				if (_p66.ctor === '[]') {
					return _elm_lang$core$Maybe$Nothing;
				} else {
					if (_elm_lang$core$Native_Utils.eq(k, 0)) {
						return _elm_lang$core$Maybe$Just(_p66._0);
					} else {
						var _v30 = k - 1,
							_v31 = _p66._1;
						k = _v30;
						ys = _v31;
						continue find;
					}
				}
			}
		});
	return function (xs) {
		return A2(
			_mgold$elm_random_pcg$Random_Pcg$map,
			function (i) {
				return A2(find, i, xs);
			},
			A2(
				_mgold$elm_random_pcg$Random_Pcg$int,
				0,
				_elm_lang$core$List$length(xs) - 1));
	};
}();
var _mgold$elm_random_pcg$Random_Pcg$float = F2(
	function (min, max) {
		return _mgold$elm_random_pcg$Random_Pcg$Generator(
			function (seed0) {
				var range = _elm_lang$core$Basics$abs(max - min);
				var n0 = _mgold$elm_random_pcg$Random_Pcg$peel(seed0);
				var hi = _elm_lang$core$Basics$toFloat(67108863 & n0) * 1.0;
				var seed1 = _mgold$elm_random_pcg$Random_Pcg$next(seed0);
				var n1 = _mgold$elm_random_pcg$Random_Pcg$peel(seed1);
				var lo = _elm_lang$core$Basics$toFloat(134217727 & n1) * 1.0;
				var val = ((hi * _mgold$elm_random_pcg$Random_Pcg$bit27) + lo) / _mgold$elm_random_pcg$Random_Pcg$bit53;
				var scaled = (val * range) + min;
				return {
					ctor: '_Tuple2',
					_0: scaled,
					_1: _mgold$elm_random_pcg$Random_Pcg$next(seed1)
				};
			});
	});
var _mgold$elm_random_pcg$Random_Pcg$frequency = function (pairs) {
	var pick = F2(
		function (choices, n) {
			pick:
			while (true) {
				var _p67 = choices;
				if ((_p67.ctor === '::') && (_p67._0.ctor === '_Tuple2')) {
					var _p68 = _p67._0._0;
					if (_elm_lang$core$Native_Utils.cmp(n, _p68) < 1) {
						return _p67._0._1;
					} else {
						var _v33 = _p67._1,
							_v34 = n - _p68;
						choices = _v33;
						n = _v34;
						continue pick;
					}
				} else {
					return _elm_lang$core$Native_Utils.crashCase(
						'Random.Pcg',
						{
							start: {line: 682, column: 13},
							end: {line: 690, column: 77}
						},
						_p67)('Empty list passed to Random.Pcg.frequency!');
				}
			}
		});
	var total = _elm_lang$core$List$sum(
		A2(
			_elm_lang$core$List$map,
			function (_p70) {
				return _elm_lang$core$Basics$abs(
					_elm_lang$core$Tuple$first(_p70));
			},
			pairs));
	return A2(
		_mgold$elm_random_pcg$Random_Pcg$andThen,
		pick(pairs),
		A2(_mgold$elm_random_pcg$Random_Pcg$float, 0, total));
};
var _mgold$elm_random_pcg$Random_Pcg$choices = function (gens) {
	return _mgold$elm_random_pcg$Random_Pcg$frequency(
		A2(
			_elm_lang$core$List$map,
			function (g) {
				return {ctor: '_Tuple2', _0: 1, _1: g};
			},
			gens));
};
var _mgold$elm_random_pcg$Random_Pcg$independentSeed = _mgold$elm_random_pcg$Random_Pcg$Generator(
	function (seed0) {
		var gen = A2(_mgold$elm_random_pcg$Random_Pcg$int, 0, 4294967295);
		var _p71 = A2(
			_mgold$elm_random_pcg$Random_Pcg$step,
			A4(
				_mgold$elm_random_pcg$Random_Pcg$map3,
				F3(
					function (v0, v1, v2) {
						return {ctor: '_Tuple3', _0: v0, _1: v1, _2: v2};
					}),
				gen,
				gen,
				gen),
			seed0);
		var state = _p71._0._0;
		var b = _p71._0._1;
		var c = _p71._0._2;
		var seed1 = _p71._1;
		var incr = 1 | (b ^ c);
		return {
			ctor: '_Tuple2',
			_0: seed1,
			_1: _mgold$elm_random_pcg$Random_Pcg$next(
				A2(_mgold$elm_random_pcg$Random_Pcg$Seed, state, incr))
		};
	});
var _mgold$elm_random_pcg$Random_Pcg$fastForward = F2(
	function (delta0, _p72) {
		var _p73 = _p72;
		var _p76 = _p73._1;
		var helper = F6(
			function (accMult, accPlus, curMult, curPlus, delta, repeat) {
				helper:
				while (true) {
					var newDelta = delta >>> 1;
					var curMult_ = A2(_mgold$elm_random_pcg$Random_Pcg$mul32, curMult, curMult);
					var curPlus_ = A2(_mgold$elm_random_pcg$Random_Pcg$mul32, curMult + 1, curPlus);
					var _p74 = _elm_lang$core$Native_Utils.eq(delta & 1, 1) ? {
						ctor: '_Tuple2',
						_0: A2(_mgold$elm_random_pcg$Random_Pcg$mul32, accMult, curMult),
						_1: (A2(_mgold$elm_random_pcg$Random_Pcg$mul32, accPlus, curMult) + curPlus) >>> 0
					} : {ctor: '_Tuple2', _0: accMult, _1: accPlus};
					var accMult_ = _p74._0;
					var accPlus_ = _p74._1;
					if (_elm_lang$core$Native_Utils.eq(newDelta, 0)) {
						if ((_elm_lang$core$Native_Utils.cmp(delta0, 0) < 0) && repeat) {
							var _v36 = accMult_,
								_v37 = accPlus_,
								_v38 = curMult_,
								_v39 = curPlus_,
								_v40 = -1,
								_v41 = false;
							accMult = _v36;
							accPlus = _v37;
							curMult = _v38;
							curPlus = _v39;
							delta = _v40;
							repeat = _v41;
							continue helper;
						} else {
							return {ctor: '_Tuple2', _0: accMult_, _1: accPlus_};
						}
					} else {
						var _v42 = accMult_,
							_v43 = accPlus_,
							_v44 = curMult_,
							_v45 = curPlus_,
							_v46 = newDelta,
							_v47 = repeat;
						accMult = _v42;
						accPlus = _v43;
						curMult = _v44;
						curPlus = _v45;
						delta = _v46;
						repeat = _v47;
						continue helper;
					}
				}
			});
		var _p75 = A6(helper, 1, 0, 1664525, _p76, delta0, true);
		var accMultFinal = _p75._0;
		var accPlusFinal = _p75._1;
		return A2(
			_mgold$elm_random_pcg$Random_Pcg$Seed,
			(A2(_mgold$elm_random_pcg$Random_Pcg$mul32, accMultFinal, _p73._0) + accPlusFinal) >>> 0,
			_p76);
	});
var _mgold$elm_random_pcg$Random_Pcg$fromJson = _elm_lang$core$Json_Decode$oneOf(
	{
		ctor: '::',
		_0: A3(
			_elm_lang$core$Json_Decode$map2,
			_mgold$elm_random_pcg$Random_Pcg$Seed,
			A2(_elm_lang$core$Json_Decode$index, 0, _elm_lang$core$Json_Decode$int),
			A2(_elm_lang$core$Json_Decode$index, 1, _elm_lang$core$Json_Decode$int)),
		_1: {
			ctor: '::',
			_0: A2(_elm_lang$core$Json_Decode$map, _mgold$elm_random_pcg$Random_Pcg$initialSeed, _elm_lang$core$Json_Decode$int),
			_1: {ctor: '[]'}
		}
	});

//import Maybe, Native.List //

var _elm_lang$core$Native_Regex = function() {

function escape(str)
{
	return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
}
function caseInsensitive(re)
{
	return new RegExp(re.source, 'gi');
}
function regex(raw)
{
	return new RegExp(raw, 'g');
}

function contains(re, string)
{
	return string.match(re) !== null;
}

function find(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex === re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		out.push({
			match: result[0],
			submatches: _elm_lang$core$Native_List.fromArray(subs),
			index: result.index,
			number: number
		});
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

function replace(n, re, replacer, string)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		return replacer({
			match: match,
			submatches: _elm_lang$core$Native_List.fromArray(submatches),
			index: arguments[arguments.length - 2],
			number: count
		});
	}
	return string.replace(re, jsReplacer);
}

function split(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	if (n === Infinity)
	{
		return _elm_lang$core$Native_List.fromArray(str.split(re));
	}
	var string = str;
	var result;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		if (!(result = re.exec(string))) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

return {
	regex: regex,
	caseInsensitive: caseInsensitive,
	escape: escape,

	contains: F2(contains),
	find: F3(find),
	replace: F4(replace),
	split: F3(split)
};

}();

var _elm_lang$core$Regex$split = _elm_lang$core$Native_Regex.split;
var _elm_lang$core$Regex$replace = _elm_lang$core$Native_Regex.replace;
var _elm_lang$core$Regex$find = _elm_lang$core$Native_Regex.find;
var _elm_lang$core$Regex$contains = _elm_lang$core$Native_Regex.contains;
var _elm_lang$core$Regex$caseInsensitive = _elm_lang$core$Native_Regex.caseInsensitive;
var _elm_lang$core$Regex$regex = _elm_lang$core$Native_Regex.regex;
var _elm_lang$core$Regex$escape = _elm_lang$core$Native_Regex.escape;
var _elm_lang$core$Regex$Match = F4(
	function (a, b, c, d) {
		return {match: a, submatches: b, index: c, number: d};
	});
var _elm_lang$core$Regex$Regex = {ctor: 'Regex'};
var _elm_lang$core$Regex$AtMost = function (a) {
	return {ctor: 'AtMost', _0: a};
};
var _elm_lang$core$Regex$All = {ctor: 'All'};

var _danyx23$elm_uuid$Uuid_Barebones$hexGenerator = A2(_mgold$elm_random_pcg$Random_Pcg$int, 0, 15);
var _danyx23$elm_uuid$Uuid_Barebones$hexDigits = function () {
	var mapChars = F2(
		function (offset, digit) {
			return _elm_lang$core$Char$fromCode(digit + offset);
		});
	return _elm_lang$core$Array$fromList(
		A2(
			_elm_lang$core$Basics_ops['++'],
			A2(
				_elm_lang$core$List$map,
				mapChars(48),
				A2(_elm_lang$core$List$range, 0, 9)),
			A2(
				_elm_lang$core$List$map,
				mapChars(97),
				A2(_elm_lang$core$List$range, 0, 5))));
}();
var _danyx23$elm_uuid$Uuid_Barebones$mapToHex = function (index) {
	var maybeResult = A2(_elm_lang$core$Basics$flip, _elm_lang$core$Array$get, _danyx23$elm_uuid$Uuid_Barebones$hexDigits)(index);
	var _p0 = maybeResult;
	if (_p0.ctor === 'Nothing') {
		return _elm_lang$core$Native_Utils.chr('x');
	} else {
		return _p0._0;
	}
};
var _danyx23$elm_uuid$Uuid_Barebones$uuidRegex = _elm_lang$core$Regex$regex('^[0-9A-Fa-f]{8,8}-[0-9A-Fa-f]{4,4}-[1-5][0-9A-Fa-f]{3,3}-[8-9A-Ba-b][0-9A-Fa-f]{3,3}-[0-9A-Fa-f]{12,12}$');
var _danyx23$elm_uuid$Uuid_Barebones$limitDigitRange8ToB = function (digit) {
	return (digit & 3) | 8;
};
var _danyx23$elm_uuid$Uuid_Barebones$toUuidString = function (thirtyOneHexDigits) {
	return _elm_lang$core$String$concat(
		{
			ctor: '::',
			_0: _elm_lang$core$String$fromList(
				A2(
					_elm_lang$core$List$map,
					_danyx23$elm_uuid$Uuid_Barebones$mapToHex,
					A2(_elm_lang$core$List$take, 8, thirtyOneHexDigits))),
			_1: {
				ctor: '::',
				_0: '-',
				_1: {
					ctor: '::',
					_0: _elm_lang$core$String$fromList(
						A2(
							_elm_lang$core$List$map,
							_danyx23$elm_uuid$Uuid_Barebones$mapToHex,
							A2(
								_elm_lang$core$List$take,
								4,
								A2(_elm_lang$core$List$drop, 8, thirtyOneHexDigits)))),
					_1: {
						ctor: '::',
						_0: '-',
						_1: {
							ctor: '::',
							_0: '4',
							_1: {
								ctor: '::',
								_0: _elm_lang$core$String$fromList(
									A2(
										_elm_lang$core$List$map,
										_danyx23$elm_uuid$Uuid_Barebones$mapToHex,
										A2(
											_elm_lang$core$List$take,
											3,
											A2(_elm_lang$core$List$drop, 12, thirtyOneHexDigits)))),
								_1: {
									ctor: '::',
									_0: '-',
									_1: {
										ctor: '::',
										_0: _elm_lang$core$String$fromList(
											A2(
												_elm_lang$core$List$map,
												_danyx23$elm_uuid$Uuid_Barebones$mapToHex,
												A2(
													_elm_lang$core$List$map,
													_danyx23$elm_uuid$Uuid_Barebones$limitDigitRange8ToB,
													A2(
														_elm_lang$core$List$take,
														1,
														A2(_elm_lang$core$List$drop, 15, thirtyOneHexDigits))))),
										_1: {
											ctor: '::',
											_0: _elm_lang$core$String$fromList(
												A2(
													_elm_lang$core$List$map,
													_danyx23$elm_uuid$Uuid_Barebones$mapToHex,
													A2(
														_elm_lang$core$List$take,
														3,
														A2(_elm_lang$core$List$drop, 16, thirtyOneHexDigits)))),
											_1: {
												ctor: '::',
												_0: '-',
												_1: {
													ctor: '::',
													_0: _elm_lang$core$String$fromList(
														A2(
															_elm_lang$core$List$map,
															_danyx23$elm_uuid$Uuid_Barebones$mapToHex,
															A2(
																_elm_lang$core$List$take,
																12,
																A2(_elm_lang$core$List$drop, 19, thirtyOneHexDigits)))),
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		});
};
var _danyx23$elm_uuid$Uuid_Barebones$isValidUuid = function (uuidAsString) {
	return A2(_elm_lang$core$Regex$contains, _danyx23$elm_uuid$Uuid_Barebones$uuidRegex, uuidAsString);
};
var _danyx23$elm_uuid$Uuid_Barebones$uuidStringGenerator = A2(
	_mgold$elm_random_pcg$Random_Pcg$map,
	_danyx23$elm_uuid$Uuid_Barebones$toUuidString,
	A2(_mgold$elm_random_pcg$Random_Pcg$list, 31, _danyx23$elm_uuid$Uuid_Barebones$hexGenerator));

var _danyx23$elm_uuid$Uuid$toString = function (_p0) {
	var _p1 = _p0;
	return _p1._0;
};
var _danyx23$elm_uuid$Uuid$Uuid = function (a) {
	return {ctor: 'Uuid', _0: a};
};
var _danyx23$elm_uuid$Uuid$fromString = function (text) {
	return _danyx23$elm_uuid$Uuid_Barebones$isValidUuid(text) ? _elm_lang$core$Maybe$Just(
		_danyx23$elm_uuid$Uuid$Uuid(
			_elm_lang$core$String$toLower(text))) : _elm_lang$core$Maybe$Nothing;
};
var _danyx23$elm_uuid$Uuid$uuidGenerator = A2(_mgold$elm_random_pcg$Random_Pcg$map, _danyx23$elm_uuid$Uuid$Uuid, _danyx23$elm_uuid$Uuid_Barebones$uuidStringGenerator);

var _elm_lang$core$Process$kill = _elm_lang$core$Native_Scheduler.kill;
var _elm_lang$core$Process$sleep = _elm_lang$core$Native_Scheduler.sleep;
var _elm_lang$core$Process$spawn = _elm_lang$core$Native_Scheduler.spawn;

var _elm_lang$dom$Native_Dom = function() {

var fakeNode = {
	addEventListener: function() {},
	removeEventListener: function() {}
};

var onDocument = on(typeof document !== 'undefined' ? document : fakeNode);
var onWindow = on(typeof window !== 'undefined' ? window : fakeNode);

function on(node)
{
	return function(eventName, decoder, toTask)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {

			function performTask(event)
			{
				var result = A2(_elm_lang$core$Json_Decode$decodeValue, decoder, event);
				if (result.ctor === 'Ok')
				{
					_elm_lang$core$Native_Scheduler.rawSpawn(toTask(result._0));
				}
			}

			node.addEventListener(eventName, performTask);

			return function()
			{
				node.removeEventListener(eventName, performTask);
			};
		});
	};
}

var rAF = typeof requestAnimationFrame !== 'undefined'
	? requestAnimationFrame
	: function(callback) { callback(); };

function withNode(id, doStuff)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		rAF(function()
		{
			var node = document.getElementById(id);
			if (node === null)
			{
				callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NotFound', _0: id }));
				return;
			}
			callback(_elm_lang$core$Native_Scheduler.succeed(doStuff(node)));
		});
	});
}


// FOCUS

function focus(id)
{
	return withNode(id, function(node) {
		node.focus();
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function blur(id)
{
	return withNode(id, function(node) {
		node.blur();
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}


// SCROLLING

function getScrollTop(id)
{
	return withNode(id, function(node) {
		return node.scrollTop;
	});
}

function setScrollTop(id, desiredScrollTop)
{
	return withNode(id, function(node) {
		node.scrollTop = desiredScrollTop;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function toBottom(id)
{
	return withNode(id, function(node) {
		node.scrollTop = node.scrollHeight;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function getScrollLeft(id)
{
	return withNode(id, function(node) {
		return node.scrollLeft;
	});
}

function setScrollLeft(id, desiredScrollLeft)
{
	return withNode(id, function(node) {
		node.scrollLeft = desiredScrollLeft;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}

function toRight(id)
{
	return withNode(id, function(node) {
		node.scrollLeft = node.scrollWidth;
		return _elm_lang$core$Native_Utils.Tuple0;
	});
}


// SIZE

function width(options, id)
{
	return withNode(id, function(node) {
		switch (options.ctor)
		{
			case 'Content':
				return node.scrollWidth;
			case 'VisibleContent':
				return node.clientWidth;
			case 'VisibleContentWithBorders':
				return node.offsetWidth;
			case 'VisibleContentWithBordersAndMargins':
				var rect = node.getBoundingClientRect();
				return rect.right - rect.left;
		}
	});
}

function height(options, id)
{
	return withNode(id, function(node) {
		switch (options.ctor)
		{
			case 'Content':
				return node.scrollHeight;
			case 'VisibleContent':
				return node.clientHeight;
			case 'VisibleContentWithBorders':
				return node.offsetHeight;
			case 'VisibleContentWithBordersAndMargins':
				var rect = node.getBoundingClientRect();
				return rect.bottom - rect.top;
		}
	});
}

return {
	onDocument: F3(onDocument),
	onWindow: F3(onWindow),

	focus: focus,
	blur: blur,

	getScrollTop: getScrollTop,
	setScrollTop: F2(setScrollTop),
	getScrollLeft: getScrollLeft,
	setScrollLeft: F2(setScrollLeft),
	toBottom: toBottom,
	toRight: toRight,

	height: F2(height),
	width: F2(width)
};

}();

var _elm_lang$dom$Dom$blur = _elm_lang$dom$Native_Dom.blur;
var _elm_lang$dom$Dom$focus = _elm_lang$dom$Native_Dom.focus;
var _elm_lang$dom$Dom$NotFound = function (a) {
	return {ctor: 'NotFound', _0: a};
};

var _elm_lang$dom$Dom_LowLevel$onWindow = _elm_lang$dom$Native_Dom.onWindow;
var _elm_lang$dom$Dom_LowLevel$onDocument = _elm_lang$dom$Native_Dom.onDocument;

var _elm_lang$dom$Dom_Size$width = _elm_lang$dom$Native_Dom.width;
var _elm_lang$dom$Dom_Size$height = _elm_lang$dom$Native_Dom.height;
var _elm_lang$dom$Dom_Size$VisibleContentWithBordersAndMargins = {ctor: 'VisibleContentWithBordersAndMargins'};
var _elm_lang$dom$Dom_Size$VisibleContentWithBorders = {ctor: 'VisibleContentWithBorders'};
var _elm_lang$dom$Dom_Size$VisibleContent = {ctor: 'VisibleContent'};
var _elm_lang$dom$Dom_Size$Content = {ctor: 'Content'};

var _elm_lang$dom$Dom_Scroll$toX = _elm_lang$dom$Native_Dom.setScrollLeft;
var _elm_lang$dom$Dom_Scroll$x = _elm_lang$dom$Native_Dom.getScrollLeft;
var _elm_lang$dom$Dom_Scroll$toRight = _elm_lang$dom$Native_Dom.toRight;
var _elm_lang$dom$Dom_Scroll$toLeft = function (id) {
	return A2(_elm_lang$dom$Dom_Scroll$toX, id, 0);
};
var _elm_lang$dom$Dom_Scroll$toY = _elm_lang$dom$Native_Dom.setScrollTop;
var _elm_lang$dom$Dom_Scroll$y = _elm_lang$dom$Native_Dom.getScrollTop;
var _elm_lang$dom$Dom_Scroll$toBottom = _elm_lang$dom$Native_Dom.toBottom;
var _elm_lang$dom$Dom_Scroll$toTop = function (id) {
	return A2(_elm_lang$dom$Dom_Scroll$toY, id, 0);
};

var _elm_lang$virtual_dom$VirtualDom_Debug$wrap;
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags;

var _elm_lang$virtual_dom$Native_VirtualDom = function() {

var STYLE_KEY = 'STYLE';
var EVENT_KEY = 'EVENT';
var ATTR_KEY = 'ATTR';
var ATTR_NS_KEY = 'ATTR_NS';

var localDoc = typeof document !== 'undefined' ? document : {};


////////////  VIRTUAL DOM NODES  ////////////


function text(string)
{
	return {
		type: 'text',
		text: string
	};
}


function node(tag)
{
	return F2(function(factList, kidList) {
		return nodeHelp(tag, factList, kidList);
	});
}


function nodeHelp(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function keyedNode(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid._1.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'keyed-node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function custom(factList, model, impl)
{
	var facts = organizeFacts(factList).facts;

	return {
		type: 'custom',
		facts: facts,
		model: model,
		impl: impl
	};
}


function map(tagger, node)
{
	return {
		type: 'tagger',
		tagger: tagger,
		node: node,
		descendantsCount: 1 + (node.descendantsCount || 0)
	};
}


function thunk(func, args, thunk)
{
	return {
		type: 'thunk',
		func: func,
		args: args,
		thunk: thunk,
		node: undefined
	};
}

function lazy(fn, a)
{
	return thunk(fn, [a], function() {
		return fn(a);
	});
}

function lazy2(fn, a, b)
{
	return thunk(fn, [a,b], function() {
		return A2(fn, a, b);
	});
}

function lazy3(fn, a, b, c)
{
	return thunk(fn, [a,b,c], function() {
		return A3(fn, a, b, c);
	});
}



// FACTS


function organizeFacts(factList)
{
	var namespace, facts = {};

	while (factList.ctor !== '[]')
	{
		var entry = factList._0;
		var key = entry.key;

		if (key === ATTR_KEY || key === ATTR_NS_KEY || key === EVENT_KEY)
		{
			var subFacts = facts[key] || {};
			subFacts[entry.realKey] = entry.value;
			facts[key] = subFacts;
		}
		else if (key === STYLE_KEY)
		{
			var styles = facts[key] || {};
			var styleList = entry.value;
			while (styleList.ctor !== '[]')
			{
				var style = styleList._0;
				styles[style._0] = style._1;
				styleList = styleList._1;
			}
			facts[key] = styles;
		}
		else if (key === 'namespace')
		{
			namespace = entry.value;
		}
		else if (key === 'className')
		{
			var classes = facts[key];
			facts[key] = typeof classes === 'undefined'
				? entry.value
				: classes + ' ' + entry.value;
		}
 		else
		{
			facts[key] = entry.value;
		}
		factList = factList._1;
	}

	return {
		facts: facts,
		namespace: namespace
	};
}



////////////  PROPERTIES AND ATTRIBUTES  ////////////


function style(value)
{
	return {
		key: STYLE_KEY,
		value: value
	};
}


function property(key, value)
{
	return {
		key: key,
		value: value
	};
}


function attribute(key, value)
{
	return {
		key: ATTR_KEY,
		realKey: key,
		value: value
	};
}


function attributeNS(namespace, key, value)
{
	return {
		key: ATTR_NS_KEY,
		realKey: key,
		value: {
			value: value,
			namespace: namespace
		}
	};
}


function on(name, options, decoder)
{
	return {
		key: EVENT_KEY,
		realKey: name,
		value: {
			options: options,
			decoder: decoder
		}
	};
}


function equalEvents(a, b)
{
	if (a.options !== b.options)
	{
		if (a.options.stopPropagation !== b.options.stopPropagation || a.options.preventDefault !== b.options.preventDefault)
		{
			return false;
		}
	}
	return _elm_lang$core$Native_Json.equality(a.decoder, b.decoder);
}


function mapProperty(func, property)
{
	if (property.key !== EVENT_KEY)
	{
		return property;
	}
	return on(
		property.realKey,
		property.value.options,
		A2(_elm_lang$core$Json_Decode$map, func, property.value.decoder)
	);
}


////////////  RENDER  ////////////


function render(vNode, eventNode)
{
	switch (vNode.type)
	{
		case 'thunk':
			if (!vNode.node)
			{
				vNode.node = vNode.thunk();
			}
			return render(vNode.node, eventNode);

		case 'tagger':
			var subNode = vNode.node;
			var tagger = vNode.tagger;

			while (subNode.type === 'tagger')
			{
				typeof tagger !== 'object'
					? tagger = [tagger, subNode.tagger]
					: tagger.push(subNode.tagger);

				subNode = subNode.node;
			}

			var subEventRoot = { tagger: tagger, parent: eventNode };
			var domNode = render(subNode, subEventRoot);
			domNode.elm_event_node_ref = subEventRoot;
			return domNode;

		case 'text':
			return localDoc.createTextNode(vNode.text);

		case 'node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i], eventNode));
			}

			return domNode;

		case 'keyed-node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i]._1, eventNode));
			}

			return domNode;

		case 'custom':
			var domNode = vNode.impl.render(vNode.model);
			applyFacts(domNode, eventNode, vNode.facts);
			return domNode;
	}
}



////////////  APPLY FACTS  ////////////


function applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		switch (key)
		{
			case STYLE_KEY:
				applyStyles(domNode, value);
				break;

			case EVENT_KEY:
				applyEvents(domNode, eventNode, value);
				break;

			case ATTR_KEY:
				applyAttrs(domNode, value);
				break;

			case ATTR_NS_KEY:
				applyAttrsNS(domNode, value);
				break;

			case 'value':
				if (domNode[key] !== value)
				{
					domNode[key] = value;
				}
				break;

			default:
				domNode[key] = value;
				break;
		}
	}
}

function applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}

function applyEvents(domNode, eventNode, events)
{
	var allHandlers = domNode.elm_handlers || {};

	for (var key in events)
	{
		var handler = allHandlers[key];
		var value = events[key];

		if (typeof value === 'undefined')
		{
			domNode.removeEventListener(key, handler);
			allHandlers[key] = undefined;
		}
		else if (typeof handler === 'undefined')
		{
			var handler = makeEventHandler(eventNode, value);
			domNode.addEventListener(key, handler);
			allHandlers[key] = handler;
		}
		else
		{
			handler.info = value;
		}
	}

	domNode.elm_handlers = allHandlers;
}

function makeEventHandler(eventNode, info)
{
	function eventHandler(event)
	{
		var info = eventHandler.info;

		var value = A2(_elm_lang$core$Native_Json.run, info.decoder, event);

		if (value.ctor === 'Ok')
		{
			var options = info.options;
			if (options.stopPropagation)
			{
				event.stopPropagation();
			}
			if (options.preventDefault)
			{
				event.preventDefault();
			}

			var message = value._0;

			var currentEventNode = eventNode;
			while (currentEventNode)
			{
				var tagger = currentEventNode.tagger;
				if (typeof tagger === 'function')
				{
					message = tagger(message);
				}
				else
				{
					for (var i = tagger.length; i--; )
					{
						message = tagger[i](message);
					}
				}
				currentEventNode = currentEventNode.parent;
			}
		}
	};

	eventHandler.info = info;

	return eventHandler;
}

function applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		if (typeof value === 'undefined')
		{
			domNode.removeAttribute(key);
		}
		else
		{
			domNode.setAttribute(key, value);
		}
	}
}

function applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.namespace;
		var value = pair.value;

		if (typeof value === 'undefined')
		{
			domNode.removeAttributeNS(namespace, key);
		}
		else
		{
			domNode.setAttributeNS(namespace, key, value);
		}
	}
}



////////////  DIFF  ////////////


function diff(a, b)
{
	var patches = [];
	diffHelp(a, b, patches, 0);
	return patches;
}


function makePatch(type, index, data)
{
	return {
		index: index,
		type: type,
		data: data,
		domNode: undefined,
		eventNode: undefined
	};
}


function diffHelp(a, b, patches, index)
{
	if (a === b)
	{
		return;
	}

	var aType = a.type;
	var bType = b.type;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (aType !== bType)
	{
		patches.push(makePatch('p-redraw', index, b));
		return;
	}

	// Now we know that both nodes are the same type.
	switch (bType)
	{
		case 'thunk':
			var aArgs = a.args;
			var bArgs = b.args;
			var i = aArgs.length;
			var same = a.func === b.func && i === bArgs.length;
			while (same && i--)
			{
				same = aArgs[i] === bArgs[i];
			}
			if (same)
			{
				b.node = a.node;
				return;
			}
			b.node = b.thunk();
			var subPatches = [];
			diffHelp(a.node, b.node, subPatches, 0);
			if (subPatches.length > 0)
			{
				patches.push(makePatch('p-thunk', index, subPatches));
			}
			return;

		case 'tagger':
			// gather nested taggers
			var aTaggers = a.tagger;
			var bTaggers = b.tagger;
			var nesting = false;

			var aSubNode = a.node;
			while (aSubNode.type === 'tagger')
			{
				nesting = true;

				typeof aTaggers !== 'object'
					? aTaggers = [aTaggers, aSubNode.tagger]
					: aTaggers.push(aSubNode.tagger);

				aSubNode = aSubNode.node;
			}

			var bSubNode = b.node;
			while (bSubNode.type === 'tagger')
			{
				nesting = true;

				typeof bTaggers !== 'object'
					? bTaggers = [bTaggers, bSubNode.tagger]
					: bTaggers.push(bSubNode.tagger);

				bSubNode = bSubNode.node;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && aTaggers.length !== bTaggers.length)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !pairwiseRefEqual(aTaggers, bTaggers) : aTaggers !== bTaggers)
			{
				patches.push(makePatch('p-tagger', index, bTaggers));
			}

			// diff everything below the taggers
			diffHelp(aSubNode, bSubNode, patches, index + 1);
			return;

		case 'text':
			if (a.text !== b.text)
			{
				patches.push(makePatch('p-text', index, b.text));
				return;
			}

			return;

		case 'node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffChildren(a, b, patches, index);
			return;

		case 'keyed-node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffKeyedChildren(a, b, patches, index);
			return;

		case 'custom':
			if (a.impl !== b.impl)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);
			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			var patch = b.impl.diff(a,b);
			if (patch)
			{
				patches.push(makePatch('p-custom', index, patch));
				return;
			}

			return;
	}
}


// assumes the incoming arrays are the same length
function pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function diffFacts(a, b, category)
{
	var diff;

	// look for changes and removals
	for (var aKey in a)
	{
		if (aKey === STYLE_KEY || aKey === EVENT_KEY || aKey === ATTR_KEY || aKey === ATTR_NS_KEY)
		{
			var subDiff = diffFacts(a[aKey], b[aKey] || {}, aKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[aKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(aKey in b))
		{
			diff = diff || {};
			diff[aKey] =
				(typeof category === 'undefined')
					? (typeof a[aKey] === 'string' ? '' : null)
					:
				(category === STYLE_KEY)
					? ''
					:
				(category === EVENT_KEY || category === ATTR_KEY)
					? undefined
					:
				{ namespace: a[aKey].namespace, value: undefined };

			continue;
		}

		var aValue = a[aKey];
		var bValue = b[aKey];

		// reference equal, so don't worry about it
		if (aValue === bValue && aKey !== 'value'
			|| category === EVENT_KEY && equalEvents(aValue, bValue))
		{
			continue;
		}

		diff = diff || {};
		diff[aKey] = bValue;
	}

	// add new stuff
	for (var bKey in b)
	{
		if (!(bKey in a))
		{
			diff = diff || {};
			diff[bKey] = b[bKey];
		}
	}

	return diff;
}


function diffChildren(aParent, bParent, patches, rootIndex)
{
	var aChildren = aParent.children;
	var bChildren = bParent.children;

	var aLen = aChildren.length;
	var bLen = bChildren.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (aLen > bLen)
	{
		patches.push(makePatch('p-remove-last', rootIndex, aLen - bLen));
	}
	else if (aLen < bLen)
	{
		patches.push(makePatch('p-append', rootIndex, bChildren.slice(aLen)));
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	var index = rootIndex;
	var minLen = aLen < bLen ? aLen : bLen;
	for (var i = 0; i < minLen; i++)
	{
		index++;
		var aChild = aChildren[i];
		diffHelp(aChild, bChildren[i], patches, index);
		index += aChild.descendantsCount || 0;
	}
}



////////////  KEYED DIFF  ////////////


function diffKeyedChildren(aParent, bParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var aChildren = aParent.children;
	var bChildren = bParent.children;
	var aLen = aChildren.length;
	var bLen = bChildren.length;
	var aIndex = 0;
	var bIndex = 0;

	var index = rootIndex;

	while (aIndex < aLen && bIndex < bLen)
	{
		var a = aChildren[aIndex];
		var b = bChildren[bIndex];

		var aKey = a._0;
		var bKey = b._0;
		var aNode = a._1;
		var bNode = b._1;

		// check if keys match

		if (aKey === bKey)
		{
			index++;
			diffHelp(aNode, bNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex++;
			bIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var aLookAhead = aIndex + 1 < aLen;
		var bLookAhead = bIndex + 1 < bLen;

		if (aLookAhead)
		{
			var aNext = aChildren[aIndex + 1];
			var aNextKey = aNext._0;
			var aNextNode = aNext._1;
			var oldMatch = bKey === aNextKey;
		}

		if (bLookAhead)
		{
			var bNext = bChildren[bIndex + 1];
			var bNextKey = bNext._0;
			var bNextNode = bNext._1;
			var newMatch = aKey === bNextKey;
		}


		// swap a and b
		if (aLookAhead && bLookAhead && newMatch && oldMatch)
		{
			index++;
			diffHelp(aNode, bNextNode, localPatches, index);
			insertNode(changes, localPatches, aKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			removeNode(changes, localPatches, aKey, aNextNode, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		// insert b
		if (bLookAhead && newMatch)
		{
			index++;
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			diffHelp(aNode, bNextNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex += 1;
			bIndex += 2;
			continue;
		}

		// remove a
		if (aLookAhead && oldMatch)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 1;
			continue;
		}

		// remove a, insert b
		if (aLookAhead && bLookAhead && aNextKey === bNextKey)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNextNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (aIndex < aLen)
	{
		index++;
		var a = aChildren[aIndex];
		var aNode = a._1;
		removeNode(changes, localPatches, a._0, aNode, index);
		index += aNode.descendantsCount || 0;
		aIndex++;
	}

	var endInserts;
	while (bIndex < bLen)
	{
		endInserts = endInserts || [];
		var b = bChildren[bIndex];
		insertNode(changes, localPatches, b._0, b._1, undefined, endInserts);
		bIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || typeof endInserts !== 'undefined')
	{
		patches.push(makePatch('p-reorder', rootIndex, {
			patches: localPatches,
			inserts: inserts,
			endInserts: endInserts
		}));
	}
}



////////////  CHANGES FROM KEYED DIFF  ////////////


var POSTFIX = '_elmW6BL';


function insertNode(changes, localPatches, key, vnode, bIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		entry = {
			tag: 'insert',
			vnode: vnode,
			index: bIndex,
			data: undefined
		};

		inserts.push({ index: bIndex, entry: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.tag === 'remove')
	{
		inserts.push({ index: bIndex, entry: entry });

		entry.tag = 'move';
		var subPatches = [];
		diffHelp(entry.vnode, vnode, subPatches, entry.index);
		entry.index = bIndex;
		entry.data.data = {
			patches: subPatches,
			entry: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	insertNode(changes, localPatches, key + POSTFIX, vnode, bIndex, inserts);
}


function removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		var patch = makePatch('p-remove', index, undefined);
		localPatches.push(patch);

		changes[key] = {
			tag: 'remove',
			vnode: vnode,
			index: index,
			data: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.tag === 'insert')
	{
		entry.tag = 'move';
		var subPatches = [];
		diffHelp(vnode, entry.vnode, subPatches, index);

		var patch = makePatch('p-remove', index, {
			patches: subPatches,
			entry: entry
		});
		localPatches.push(patch);

		return;
	}

	// this key has already been removed or moved, a duplicate!
	removeNode(changes, localPatches, key + POSTFIX, vnode, index);
}



////////////  ADD DOM NODES  ////////////
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function addDomNodes(domNode, vNode, patches, eventNode)
{
	addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.descendantsCount, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.index;

	while (index === low)
	{
		var patchType = patch.type;

		if (patchType === 'p-thunk')
		{
			addDomNodes(domNode, vNode.node, patch.data, eventNode);
		}
		else if (patchType === 'p-reorder')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var subPatches = patch.data.patches;
			if (subPatches.length > 0)
			{
				addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 'p-remove')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var data = patch.data;
			if (typeof data !== 'undefined')
			{
				data.entry.data = domNode;
				var subPatches = data.patches;
				if (subPatches.length > 0)
				{
					addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.index) > high)
		{
			return i;
		}
	}

	switch (vNode.type)
	{
		case 'tagger':
			var subNode = vNode.node;

			while (subNode.type === "tagger")
			{
				subNode = subNode.node;
			}

			return addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);

		case 'node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j];
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'keyed-node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j]._1;
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'text':
		case 'thunk':
			throw new Error('should never traverse `text` or `thunk` nodes like this');
	}
}



////////////  APPLY PATCHES  ////////////


function applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return applyPatchesHelp(rootDomNode, patches);
}

function applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.domNode
		var newNode = applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function applyPatch(domNode, patch)
{
	switch (patch.type)
	{
		case 'p-redraw':
			return applyPatchRedraw(domNode, patch.data, patch.eventNode);

		case 'p-facts':
			applyFacts(domNode, patch.eventNode, patch.data);
			return domNode;

		case 'p-text':
			domNode.replaceData(0, domNode.length, patch.data);
			return domNode;

		case 'p-thunk':
			return applyPatchesHelp(domNode, patch.data);

		case 'p-tagger':
			if (typeof domNode.elm_event_node_ref !== 'undefined')
			{
				domNode.elm_event_node_ref.tagger = patch.data;
			}
			else
			{
				domNode.elm_event_node_ref = { tagger: patch.data, parent: patch.eventNode };
			}
			return domNode;

		case 'p-remove-last':
			var i = patch.data;
			while (i--)
			{
				domNode.removeChild(domNode.lastChild);
			}
			return domNode;

		case 'p-append':
			var newNodes = patch.data;
			for (var i = 0; i < newNodes.length; i++)
			{
				domNode.appendChild(render(newNodes[i], patch.eventNode));
			}
			return domNode;

		case 'p-remove':
			var data = patch.data;
			if (typeof data === 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.entry;
			if (typeof entry.index !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.data = applyPatchesHelp(domNode, data.patches);
			return domNode;

		case 'p-reorder':
			return applyPatchReorder(domNode, patch);

		case 'p-custom':
			var impl = patch.data;
			return impl.applyPatch(domNode, impl.data);

		default:
			throw new Error('Ran into an unknown patch!');
	}
}


function applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = render(vNode, eventNode);

	if (typeof newNode.elm_event_node_ref === 'undefined')
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function applyPatchReorder(domNode, patch)
{
	var data = patch.data;

	// remove end inserts
	var frag = applyPatchReorderEndInsertsHelp(data.endInserts, patch);

	// removals
	domNode = applyPatchesHelp(domNode, data.patches);

	// inserts
	var inserts = data.inserts;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.entry;
		var node = entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode);
		domNode.insertBefore(node, domNode.childNodes[insert.index]);
	}

	// add end inserts
	if (typeof frag !== 'undefined')
	{
		domNode.appendChild(frag);
	}

	return domNode;
}


function applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (typeof endInserts === 'undefined')
	{
		return;
	}

	var frag = localDoc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.entry;
		frag.appendChild(entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode)
		);
	}
	return frag;
}


// PROGRAMS

var program = makeProgram(checkNoFlags);
var programWithFlags = makeProgram(checkYesFlags);

function makeProgram(flagChecker)
{
	return F2(function(debugWrap, impl)
	{
		return function(flagDecoder)
		{
			return function(object, moduleName, debugMetadata)
			{
				var checker = flagChecker(flagDecoder, moduleName);
				if (typeof debugMetadata === 'undefined')
				{
					normalSetup(impl, object, moduleName, checker);
				}
				else
				{
					debugSetup(A2(debugWrap, debugMetadata, impl), object, moduleName, checker);
				}
			};
		};
	});
}

function staticProgram(vNode)
{
	var nothing = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		_elm_lang$core$Platform_Cmd$none
	);
	return A2(program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, {
		init: nothing,
		view: function() { return vNode; },
		update: F2(function() { return nothing; }),
		subscriptions: function() { return _elm_lang$core$Platform_Sub$none; }
	})();
}


// FLAG CHECKERS

function checkNoFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flags === 'undefined')
		{
			return init;
		}

		var errorMessage =
			'The `' + moduleName + '` module does not need flags.\n'
			+ 'Initialize it with no arguments and you should be all set!';

		crash(errorMessage, domNode);
	};
}

function checkYesFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flagDecoder === 'undefined')
		{
			var errorMessage =
				'Are you trying to sneak a Never value into Elm? Trickster!\n'
				+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
				+ 'Use `program` instead if you do not want flags.'

			crash(errorMessage, domNode);
		}

		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Ok')
		{
			return init(result._0);
		}

		var errorMessage =
			'Trying to initialize the `' + moduleName + '` module with an unexpected flag.\n'
			+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
			+ result._0;

		crash(errorMessage, domNode);
	};
}

function crash(errorMessage, domNode)
{
	if (domNode)
	{
		domNode.innerHTML =
			'<div style="padding-left:1em;">'
			+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
			+ '<pre style="padding-left:1em;">' + errorMessage + '</pre>'
			+ '</div>';
	}

	throw new Error(errorMessage);
}


//  NORMAL SETUP

function normalSetup(impl, object, moduleName, flagChecker)
{
	object['embed'] = function embed(node, flags)
	{
		while (node.lastChild)
		{
			node.removeChild(node.lastChild);
		}

		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update,
			impl.subscriptions,
			normalRenderer(node, impl.view)
		);
	};

	object['fullscreen'] = function fullscreen(flags)
	{
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update,
			impl.subscriptions,
			normalRenderer(document.body, impl.view)
		);
	};
}

function normalRenderer(parentNode, view)
{
	return function(tagger, initialModel)
	{
		var eventNode = { tagger: tagger, parent: undefined };
		var initialVirtualNode = view(initialModel);
		var domNode = render(initialVirtualNode, eventNode);
		parentNode.appendChild(domNode);
		return makeStepper(domNode, view, initialVirtualNode, eventNode);
	};
}


// STEPPER

var rAF =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { setTimeout(callback, 1000 / 60); };

function makeStepper(domNode, view, initialVirtualNode, eventNode)
{
	var state = 'NO_REQUEST';
	var currNode = initialVirtualNode;
	var nextModel;

	function updateIfNeeded()
	{
		switch (state)
		{
			case 'NO_REQUEST':
				throw new Error(
					'Unexpected draw callback.\n' +
					'Please report this to <https://github.com/elm-lang/virtual-dom/issues>.'
				);

			case 'PENDING_REQUEST':
				rAF(updateIfNeeded);
				state = 'EXTRA_REQUEST';

				var nextNode = view(nextModel);
				var patches = diff(currNode, nextNode);
				domNode = applyPatches(domNode, currNode, patches, eventNode);
				currNode = nextNode;

				return;

			case 'EXTRA_REQUEST':
				state = 'NO_REQUEST';
				return;
		}
	}

	return function stepper(model)
	{
		if (state === 'NO_REQUEST')
		{
			rAF(updateIfNeeded);
		}
		state = 'PENDING_REQUEST';
		nextModel = model;
	};
}


// DEBUG SETUP

function debugSetup(impl, object, moduleName, flagChecker)
{
	object['fullscreen'] = function fullscreen(flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, document.body, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};

	object['embed'] = function fullscreen(node, flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, node, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};
}

function scrollTask(popoutRef)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var doc = popoutRef.doc;
		if (doc)
		{
			var msgs = doc.getElementsByClassName('debugger-sidebar-messages')[0];
			if (msgs)
			{
				msgs.scrollTop = msgs.scrollHeight;
			}
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


function debugRenderer(moduleName, parentNode, popoutRef, view, viewIn, viewOut)
{
	return function(tagger, initialModel)
	{
		var appEventNode = { tagger: tagger, parent: undefined };
		var eventNode = { tagger: tagger, parent: undefined };

		// make normal stepper
		var appVirtualNode = view(initialModel);
		var appNode = render(appVirtualNode, appEventNode);
		parentNode.appendChild(appNode);
		var appStepper = makeStepper(appNode, view, appVirtualNode, appEventNode);

		// make overlay stepper
		var overVirtualNode = viewIn(initialModel)._1;
		var overNode = render(overVirtualNode, eventNode);
		parentNode.appendChild(overNode);
		var wrappedViewIn = wrapViewIn(appEventNode, overNode, viewIn);
		var overStepper = makeStepper(overNode, wrappedViewIn, overVirtualNode, eventNode);

		// make debugger stepper
		var debugStepper = makeDebugStepper(initialModel, viewOut, eventNode, parentNode, moduleName, popoutRef);

		return function stepper(model)
		{
			appStepper(model);
			overStepper(model);
			debugStepper(model);
		}
	};
}

function makeDebugStepper(initialModel, view, eventNode, parentNode, moduleName, popoutRef)
{
	var curr;
	var domNode;

	return function stepper(model)
	{
		if (!model.isDebuggerOpen)
		{
			return;
		}

		if (!popoutRef.doc)
		{
			curr = view(model);
			domNode = openDebugWindow(moduleName, popoutRef, curr, eventNode);
			return;
		}

		// switch to document of popout
		localDoc = popoutRef.doc;

		var next = view(model);
		var patches = diff(curr, next);
		domNode = applyPatches(domNode, curr, patches, eventNode);
		curr = next;

		// switch back to normal document
		localDoc = document;
	};
}

function openDebugWindow(moduleName, popoutRef, virtualNode, eventNode)
{
	var w = 900;
	var h = 360;
	var x = screen.width - w;
	var y = screen.height - h;
	var debugWindow = window.open('', '', 'width=' + w + ',height=' + h + ',left=' + x + ',top=' + y);

	// switch to window document
	localDoc = debugWindow.document;

	popoutRef.doc = localDoc;
	localDoc.title = 'Debugger - ' + moduleName;
	localDoc.body.style.margin = '0';
	localDoc.body.style.padding = '0';
	var domNode = render(virtualNode, eventNode);
	localDoc.body.appendChild(domNode);

	localDoc.addEventListener('keydown', function(event) {
		if (event.metaKey && event.which === 82)
		{
			window.location.reload();
		}
		if (event.which === 38)
		{
			eventNode.tagger({ ctor: 'Up' });
			event.preventDefault();
		}
		if (event.which === 40)
		{
			eventNode.tagger({ ctor: 'Down' });
			event.preventDefault();
		}
	});

	function close()
	{
		popoutRef.doc = undefined;
		debugWindow.close();
	}
	window.addEventListener('unload', close);
	debugWindow.addEventListener('unload', function() {
		popoutRef.doc = undefined;
		window.removeEventListener('unload', close);
		eventNode.tagger({ ctor: 'Close' });
	});

	// switch back to the normal document
	localDoc = document;

	return domNode;
}


// BLOCK EVENTS

function wrapViewIn(appEventNode, overlayNode, viewIn)
{
	var ignorer = makeIgnorer(overlayNode);
	var blocking = 'Normal';
	var overflow;

	var normalTagger = appEventNode.tagger;
	var blockTagger = function() {};

	return function(model)
	{
		var tuple = viewIn(model);
		var newBlocking = tuple._0.ctor;
		appEventNode.tagger = newBlocking === 'Normal' ? normalTagger : blockTagger;
		if (blocking !== newBlocking)
		{
			traverse('removeEventListener', ignorer, blocking);
			traverse('addEventListener', ignorer, newBlocking);

			if (blocking === 'Normal')
			{
				overflow = document.body.style.overflow;
				document.body.style.overflow = 'hidden';
			}

			if (newBlocking === 'Normal')
			{
				document.body.style.overflow = overflow;
			}

			blocking = newBlocking;
		}
		return tuple._1;
	}
}

function traverse(verbEventListener, ignorer, blocking)
{
	switch(blocking)
	{
		case 'Normal':
			return;

		case 'Pause':
			return traverseHelp(verbEventListener, ignorer, mostEvents);

		case 'Message':
			return traverseHelp(verbEventListener, ignorer, allEvents);
	}
}

function traverseHelp(verbEventListener, handler, eventNames)
{
	for (var i = 0; i < eventNames.length; i++)
	{
		document.body[verbEventListener](eventNames[i], handler, true);
	}
}

function makeIgnorer(overlayNode)
{
	return function(event)
	{
		if (event.type === 'keydown' && event.metaKey && event.which === 82)
		{
			return;
		}

		var isScroll = event.type === 'scroll' || event.type === 'wheel';

		var node = event.target;
		while (node !== null)
		{
			if (node.className === 'elm-overlay-message-details' && isScroll)
			{
				return;
			}

			if (node === overlayNode && !isScroll)
			{
				return;
			}
			node = node.parentNode;
		}

		event.stopPropagation();
		event.preventDefault();
	}
}

var mostEvents = [
	'click', 'dblclick', 'mousemove',
	'mouseup', 'mousedown', 'mouseenter', 'mouseleave',
	'touchstart', 'touchend', 'touchcancel', 'touchmove',
	'pointerdown', 'pointerup', 'pointerover', 'pointerout',
	'pointerenter', 'pointerleave', 'pointermove', 'pointercancel',
	'dragstart', 'drag', 'dragend', 'dragenter', 'dragover', 'dragleave', 'drop',
	'keyup', 'keydown', 'keypress',
	'input', 'change',
	'focus', 'blur'
];

var allEvents = mostEvents.concat('wheel', 'scroll');


return {
	node: node,
	text: text,
	custom: custom,
	map: F2(map),

	on: F3(on),
	style: style,
	property: F2(property),
	attribute: F2(attribute),
	attributeNS: F3(attributeNS),
	mapProperty: F2(mapProperty),

	lazy: F2(lazy),
	lazy2: F3(lazy2),
	lazy3: F4(lazy3),
	keyedNode: F3(keyedNode),

	program: program,
	programWithFlags: programWithFlags,
	staticProgram: staticProgram
};

}();

var _elm_lang$virtual_dom$Native_Debug = function() {


// IMPORT / EXPORT

function unsafeCoerce(value)
{
	return value;
}

var upload = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
{
	var element = document.createElement('input');
	element.setAttribute('type', 'file');
	element.setAttribute('accept', 'text/json');
	element.style.display = 'none';
	element.addEventListener('change', function(event)
	{
		var fileReader = new FileReader();
		fileReader.onload = function(e)
		{
			callback(_elm_lang$core$Native_Scheduler.succeed(e.target.result));
		};
		fileReader.readAsText(event.target.files[0]);
		document.body.removeChild(element);
	});
	document.body.appendChild(element);
	element.click();
});

function download(historyLength, json)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var fileName = 'history-' + historyLength + '.txt';
		var jsonString = JSON.stringify(json);
		var mime = 'text/plain;charset=utf-8';
		var done = _elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0);

		// for IE10+
		if (navigator.msSaveBlob)
		{
			navigator.msSaveBlob(new Blob([jsonString], {type: mime}), fileName);
			return callback(done);
		}

		// for HTML5
		var element = document.createElement('a');
		element.setAttribute('href', 'data:' + mime + ',' + encodeURIComponent(jsonString));
		element.setAttribute('download', fileName);
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		callback(done);
	});
}


// POPOUT

function messageToString(value)
{
	switch (typeof value)
	{
		case 'boolean':
			return value ? 'True' : 'False';
		case 'number':
			return value + '';
		case 'string':
			return '"' + addSlashes(value, false) + '"';
	}
	if (value instanceof String)
	{
		return '\'' + addSlashes(value, true) + '\'';
	}
	if (typeof value !== 'object' || value === null || !('ctor' in value))
	{
		return '…';
	}

	var ctorStarter = value.ctor.substring(0, 5);
	if (ctorStarter === '_Tupl' || ctorStarter === '_Task')
	{
		return '…'
	}
	if (['_Array', '<decoder>', '_Process', '::', '[]', 'Set_elm_builtin', 'RBNode_elm_builtin', 'RBEmpty_elm_builtin'].indexOf(value.ctor) >= 0)
	{
		return '…';
	}

	var keys = Object.keys(value);
	switch (keys.length)
	{
		case 1:
			return value.ctor;
		case 2:
			return value.ctor + ' ' + messageToString(value._0);
		default:
			return value.ctor + ' … ' + messageToString(value[keys[keys.length - 1]]);
	}
}


function primitive(str)
{
	return { ctor: 'Primitive', _0: str };
}


function init(value)
{
	var type = typeof value;

	if (type === 'boolean')
	{
		return {
			ctor: 'Constructor',
			_0: _elm_lang$core$Maybe$Just(value ? 'True' : 'False'),
			_1: true,
			_2: _elm_lang$core$Native_List.Nil
		};
	}

	if (type === 'number')
	{
		return primitive(value + '');
	}

	if (type === 'string')
	{
		return { ctor: 'S', _0: '"' + addSlashes(value, false) + '"' };
	}

	if (value instanceof String)
	{
		return { ctor: 'S', _0: "'" + addSlashes(value, true) + "'" };
	}

	if (value instanceof Date)
	{
		return primitive('<' + value.toString() + '>');
	}

	if (value === null)
	{
		return primitive('XXX');
	}

	if (type === 'object' && 'ctor' in value)
	{
		var ctor = value.ctor;

		if (ctor === '::' || ctor === '[]')
		{
			return {
				ctor: 'Sequence',
				_0: {ctor: 'ListSeq'},
				_1: true,
				_2: A2(_elm_lang$core$List$map, init, value)
			};
		}

		if (ctor === 'Set_elm_builtin')
		{
			return {
				ctor: 'Sequence',
				_0: {ctor: 'SetSeq'},
				_1: true,
				_2: A3(_elm_lang$core$Set$foldr, initCons, _elm_lang$core$Native_List.Nil, value)
			};
		}

		if (ctor === 'RBNode_elm_builtin' || ctor == 'RBEmpty_elm_builtin')
		{
			return {
				ctor: 'Dictionary',
				_0: true,
				_1: A3(_elm_lang$core$Dict$foldr, initKeyValueCons, _elm_lang$core$Native_List.Nil, value)
			};
		}

		if (ctor === '_Array')
		{
			return {
				ctor: 'Sequence',
				_0: {ctor: 'ArraySeq'},
				_1: true,
				_2: A3(_elm_lang$core$Array$foldr, initCons, _elm_lang$core$Native_List.Nil, value)
			};
		}

		var ctorStarter = value.ctor.substring(0, 5);
		if (ctorStarter === '_Task')
		{
			return primitive('<task>');
		}

		if (ctor === '<decoder>')
		{
			return primitive(ctor);
		}

		if (ctor === '_Process')
		{
			return primitive('<process>');
		}

		var list = _elm_lang$core$Native_List.Nil;
		for (var i in value)
		{
			if (i === 'ctor') continue;
			list = _elm_lang$core$Native_List.Cons(init(value[i]), list);
		}
		return {
			ctor: 'Constructor',
			_0: ctorStarter === '_Tupl' ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(ctor),
			_1: true,
			_2: _elm_lang$core$List$reverse(list)
		};
	}

	if (type === 'object')
	{
		var dict = _elm_lang$core$Dict$empty;
		for (var i in value)
		{
			dict = A3(_elm_lang$core$Dict$insert, i, init(value[i]), dict);
		}
		return { ctor: 'Record', _0: true, _1: dict };
	}

	return primitive('XXX');
}

var initCons = F2(initConsHelp);

function initConsHelp(value, list)
{
	return _elm_lang$core$Native_List.Cons(init(value), list);
}

var initKeyValueCons = F3(initKeyValueConsHelp);

function initKeyValueConsHelp(key, value, list)
{
	return _elm_lang$core$Native_List.Cons(
		_elm_lang$core$Native_Utils.Tuple2(init(key), init(value)),
		list
	);
}

function addSlashes(str, isChar)
{
	var s = str.replace(/\\/g, '\\\\')
			  .replace(/\n/g, '\\n')
			  .replace(/\t/g, '\\t')
			  .replace(/\r/g, '\\r')
			  .replace(/\v/g, '\\v')
			  .replace(/\0/g, '\\0');
	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}


return {
	upload: upload,
	download: F2(download),
	unsafeCoerce: unsafeCoerce,
	messageToString: messageToString,
	init: init
}

}();

var _elm_lang$virtual_dom$VirtualDom_Helpers$keyedNode = _elm_lang$virtual_dom$Native_VirtualDom.keyedNode;
var _elm_lang$virtual_dom$VirtualDom_Helpers$lazy3 = _elm_lang$virtual_dom$Native_VirtualDom.lazy3;
var _elm_lang$virtual_dom$VirtualDom_Helpers$lazy2 = _elm_lang$virtual_dom$Native_VirtualDom.lazy2;
var _elm_lang$virtual_dom$VirtualDom_Helpers$lazy = _elm_lang$virtual_dom$Native_VirtualDom.lazy;
var _elm_lang$virtual_dom$VirtualDom_Helpers$defaultOptions = {stopPropagation: false, preventDefault: false};
var _elm_lang$virtual_dom$VirtualDom_Helpers$onWithOptions = _elm_lang$virtual_dom$Native_VirtualDom.on;
var _elm_lang$virtual_dom$VirtualDom_Helpers$on = F2(
	function (eventName, decoder) {
		return A3(_elm_lang$virtual_dom$VirtualDom_Helpers$onWithOptions, eventName, _elm_lang$virtual_dom$VirtualDom_Helpers$defaultOptions, decoder);
	});
var _elm_lang$virtual_dom$VirtualDom_Helpers$onClick = function (msg) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$on,
		'click',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$virtual_dom$VirtualDom_Helpers$style = _elm_lang$virtual_dom$Native_VirtualDom.style;
var _elm_lang$virtual_dom$VirtualDom_Helpers$attribute = _elm_lang$virtual_dom$Native_VirtualDom.attribute;
var _elm_lang$virtual_dom$VirtualDom_Helpers$id = _elm_lang$virtual_dom$VirtualDom_Helpers$attribute('id');
var _elm_lang$virtual_dom$VirtualDom_Helpers$property = _elm_lang$virtual_dom$Native_VirtualDom.property;
var _elm_lang$virtual_dom$VirtualDom_Helpers$class = function (name) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$property,
		'className',
		_elm_lang$core$Json_Encode$string(name));
};
var _elm_lang$virtual_dom$VirtualDom_Helpers$href = function (name) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$property,
		'href',
		_elm_lang$core$Json_Encode$string(name));
};
var _elm_lang$virtual_dom$VirtualDom_Helpers$map = _elm_lang$virtual_dom$Native_VirtualDom.map;
var _elm_lang$virtual_dom$VirtualDom_Helpers$text = _elm_lang$virtual_dom$Native_VirtualDom.text;
var _elm_lang$virtual_dom$VirtualDom_Helpers$node = _elm_lang$virtual_dom$Native_VirtualDom.node;
var _elm_lang$virtual_dom$VirtualDom_Helpers$div = _elm_lang$virtual_dom$VirtualDom_Helpers$node('div');
var _elm_lang$virtual_dom$VirtualDom_Helpers$span = _elm_lang$virtual_dom$VirtualDom_Helpers$node('span');
var _elm_lang$virtual_dom$VirtualDom_Helpers$a = _elm_lang$virtual_dom$VirtualDom_Helpers$node('a');
var _elm_lang$virtual_dom$VirtualDom_Helpers$h1 = _elm_lang$virtual_dom$VirtualDom_Helpers$node('h1');
var _elm_lang$virtual_dom$VirtualDom_Helpers$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Helpers$Node = {ctor: 'Node'};
var _elm_lang$virtual_dom$VirtualDom_Helpers$Property = {ctor: 'Property'};

var _elm_lang$virtual_dom$VirtualDom_Expando$purple = _elm_lang$virtual_dom$VirtualDom_Helpers$style(
	{
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'color', _1: 'rgb(136, 19, 145)'},
		_1: {ctor: '[]'}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$blue = _elm_lang$virtual_dom$VirtualDom_Helpers$style(
	{
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'color', _1: 'rgb(28, 0, 207)'},
		_1: {ctor: '[]'}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$red = _elm_lang$virtual_dom$VirtualDom_Helpers$style(
	{
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'color', _1: 'rgb(196, 26, 22)'},
		_1: {ctor: '[]'}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$leftPad = function (maybeKey) {
	var _p0 = maybeKey;
	if (_p0.ctor === 'Nothing') {
		return _elm_lang$virtual_dom$VirtualDom_Helpers$style(
			{ctor: '[]'});
	} else {
		return _elm_lang$virtual_dom$VirtualDom_Helpers$style(
			{
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'padding-left', _1: '4ch'},
				_1: {ctor: '[]'}
			});
	}
};
var _elm_lang$virtual_dom$VirtualDom_Expando$makeArrow = function (arrow) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$span,
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$style(
				{
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'color', _1: '#777'},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'padding-left', _1: '2ch'},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'width', _1: '2ch'},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'display', _1: 'inline-block'},
								_1: {ctor: '[]'}
							}
						}
					}
				}),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(arrow),
			_1: {ctor: '[]'}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Expando$lineStarter = F3(
	function (maybeKey, maybeIsClosed, description) {
		var arrow = function () {
			var _p1 = maybeIsClosed;
			if (_p1.ctor === 'Nothing') {
				return _elm_lang$virtual_dom$VirtualDom_Expando$makeArrow('');
			} else {
				if (_p1._0 === true) {
					return _elm_lang$virtual_dom$VirtualDom_Expando$makeArrow('▸');
				} else {
					return _elm_lang$virtual_dom$VirtualDom_Expando$makeArrow('▾');
				}
			}
		}();
		var _p2 = maybeKey;
		if (_p2.ctor === 'Nothing') {
			return {ctor: '::', _0: arrow, _1: description};
		} else {
			return {
				ctor: '::',
				_0: arrow,
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$span,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Expando$purple,
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p2._0),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' = '),
						_1: description
					}
				}
			};
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewExtraTinyRecord = F3(
	function (length, starter, entries) {
		var _p3 = entries;
		if (_p3.ctor === '[]') {
			return {
				ctor: '_Tuple2',
				_0: length + 1,
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('}'),
					_1: {ctor: '[]'}
				}
			};
		} else {
			var _p5 = _p3._0;
			var nextLength = (length + _elm_lang$core$String$length(_p5)) + 1;
			if (_elm_lang$core$Native_Utils.cmp(nextLength, 18) > 0) {
				return {
					ctor: '_Tuple2',
					_0: length + 2,
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('…}'),
						_1: {ctor: '[]'}
					}
				};
			} else {
				var _p4 = A3(_elm_lang$virtual_dom$VirtualDom_Expando$viewExtraTinyRecord, nextLength, ',', _p3._1);
				var finalLength = _p4._0;
				var otherNodes = _p4._1;
				return {
					ctor: '_Tuple2',
					_0: finalLength,
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(starter),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$span,
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Expando$purple,
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p5),
									_1: {ctor: '[]'}
								}),
							_1: otherNodes
						}
					}
				};
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$elideMiddle = function (str) {
	return (_elm_lang$core$Native_Utils.cmp(
		_elm_lang$core$String$length(str),
		18) < 1) ? str : A2(
		_elm_lang$core$Basics_ops['++'],
		A2(_elm_lang$core$String$left, 8, str),
		A2(
			_elm_lang$core$Basics_ops['++'],
			'...',
			A2(_elm_lang$core$String$right, 8, str)));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyHelp = function (str) {
	return {
		ctor: '_Tuple2',
		_0: _elm_lang$core$String$length(str),
		_1: {
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(str),
			_1: {ctor: '[]'}
		}
	};
};
var _elm_lang$virtual_dom$VirtualDom_Expando$updateIndex = F3(
	function (n, func, list) {
		var _p6 = list;
		if (_p6.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var _p8 = _p6._1;
			var _p7 = _p6._0;
			return (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) ? {
				ctor: '::',
				_0: func(_p7),
				_1: _p8
			} : {
				ctor: '::',
				_0: _p7,
				_1: A3(_elm_lang$virtual_dom$VirtualDom_Expando$updateIndex, n - 1, func, _p8)
			};
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$seqTypeToString = F2(
	function (n, seqType) {
		var _p9 = seqType;
		switch (_p9.ctor) {
			case 'ListSeq':
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'List(',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(n),
						')'));
			case 'SetSeq':
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'Set(',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(n),
						')'));
			default:
				return A2(
					_elm_lang$core$Basics_ops['++'],
					'Array(',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(n),
						')'));
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewTiny = function (value) {
	var _p10 = value;
	switch (_p10.ctor) {
		case 'S':
			var str = _elm_lang$virtual_dom$VirtualDom_Expando$elideMiddle(_p10._0);
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$String$length(str),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$span,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Expando$red,
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(str),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'Primitive':
			var _p11 = _p10._0;
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$String$length(_p11),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$span,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Expando$blue,
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p11),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			};
		case 'Sequence':
			return _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyHelp(
				A2(
					_elm_lang$virtual_dom$VirtualDom_Expando$seqTypeToString,
					_elm_lang$core$List$length(_p10._2),
					_p10._0));
		case 'Dictionary':
			return _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyHelp(
				A2(
					_elm_lang$core$Basics_ops['++'],
					'Dict(',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(
							_elm_lang$core$List$length(_p10._1)),
						')')));
		case 'Record':
			return _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyRecord(_p10._1);
		default:
			if (_p10._2.ctor === '[]') {
				return _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyHelp(
					A2(_elm_lang$core$Maybe$withDefault, 'Unit', _p10._0));
			} else {
				return _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyHelp(
					function () {
						var _p12 = _p10._0;
						if (_p12.ctor === 'Nothing') {
							return A2(
								_elm_lang$core$Basics_ops['++'],
								'Tuple(',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(
										_elm_lang$core$List$length(_p10._2)),
									')'));
						} else {
							return A2(_elm_lang$core$Basics_ops['++'], _p12._0, ' …');
						}
					}());
			}
	}
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyRecord = function (record) {
	return _elm_lang$core$Dict$isEmpty(record) ? {
		ctor: '_Tuple2',
		_0: 2,
		_1: {
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('{}'),
			_1: {ctor: '[]'}
		}
	} : A3(
		_elm_lang$virtual_dom$VirtualDom_Expando$viewTinyRecordHelp,
		0,
		'{ ',
		_elm_lang$core$Dict$toList(record));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewTinyRecordHelp = F3(
	function (length, starter, entries) {
		var _p13 = entries;
		if (_p13.ctor === '[]') {
			return {
				ctor: '_Tuple2',
				_0: length + 2,
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' }'),
					_1: {ctor: '[]'}
				}
			};
		} else {
			var _p16 = _p13._0._0;
			var _p14 = _elm_lang$virtual_dom$VirtualDom_Expando$viewExtraTiny(_p13._0._1);
			var valueLen = _p14._0;
			var valueNodes = _p14._1;
			var fieldLen = _elm_lang$core$String$length(_p16);
			var newLength = ((length + fieldLen) + valueLen) + 5;
			if (_elm_lang$core$Native_Utils.cmp(newLength, 60) > 0) {
				return {
					ctor: '_Tuple2',
					_0: length + 4,
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(', … }'),
						_1: {ctor: '[]'}
					}
				};
			} else {
				var _p15 = A3(_elm_lang$virtual_dom$VirtualDom_Expando$viewTinyRecordHelp, newLength, ', ', _p13._1);
				var finalLength = _p15._0;
				var otherNodes = _p15._1;
				return {
					ctor: '_Tuple2',
					_0: finalLength,
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(starter),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$span,
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Expando$purple,
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p16),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' = '),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$virtual_dom$VirtualDom_Helpers$span,
										{ctor: '[]'},
										valueNodes),
									_1: otherNodes
								}
							}
						}
					}
				};
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewExtraTiny = function (value) {
	var _p17 = value;
	if (_p17.ctor === 'Record') {
		return A3(
			_elm_lang$virtual_dom$VirtualDom_Expando$viewExtraTinyRecord,
			0,
			'{',
			_elm_lang$core$Dict$keys(_p17._1));
	} else {
		return _elm_lang$virtual_dom$VirtualDom_Expando$viewTiny(value);
	}
};
var _elm_lang$virtual_dom$VirtualDom_Expando$Constructor = F3(
	function (a, b, c) {
		return {ctor: 'Constructor', _0: a, _1: b, _2: c};
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$Record = F2(
	function (a, b) {
		return {ctor: 'Record', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$Dictionary = F2(
	function (a, b) {
		return {ctor: 'Dictionary', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$Sequence = F3(
	function (a, b, c) {
		return {ctor: 'Sequence', _0: a, _1: b, _2: c};
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$initHelp = F2(
	function (isOuter, expando) {
		var _p18 = expando;
		switch (_p18.ctor) {
			case 'S':
				return expando;
			case 'Primitive':
				return expando;
			case 'Sequence':
				var _p20 = _p18._0;
				var _p19 = _p18._2;
				return isOuter ? A3(
					_elm_lang$virtual_dom$VirtualDom_Expando$Sequence,
					_p20,
					false,
					A2(
						_elm_lang$core$List$map,
						_elm_lang$virtual_dom$VirtualDom_Expando$initHelp(false),
						_p19)) : ((_elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$List$length(_p19),
					8) < 1) ? A3(_elm_lang$virtual_dom$VirtualDom_Expando$Sequence, _p20, false, _p19) : expando);
			case 'Dictionary':
				var _p23 = _p18._1;
				return isOuter ? A2(
					_elm_lang$virtual_dom$VirtualDom_Expando$Dictionary,
					false,
					A2(
						_elm_lang$core$List$map,
						function (_p21) {
							var _p22 = _p21;
							return {
								ctor: '_Tuple2',
								_0: _p22._0,
								_1: A2(_elm_lang$virtual_dom$VirtualDom_Expando$initHelp, false, _p22._1)
							};
						},
						_p23)) : ((_elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$List$length(_p23),
					8) < 1) ? A2(_elm_lang$virtual_dom$VirtualDom_Expando$Dictionary, false, _p23) : expando);
			case 'Record':
				var _p25 = _p18._1;
				return isOuter ? A2(
					_elm_lang$virtual_dom$VirtualDom_Expando$Record,
					false,
					A2(
						_elm_lang$core$Dict$map,
						F2(
							function (_p24, v) {
								return A2(_elm_lang$virtual_dom$VirtualDom_Expando$initHelp, false, v);
							}),
						_p25)) : ((_elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$Dict$size(_p25),
					4) < 1) ? A2(_elm_lang$virtual_dom$VirtualDom_Expando$Record, false, _p25) : expando);
			default:
				var _p27 = _p18._0;
				var _p26 = _p18._2;
				return isOuter ? A3(
					_elm_lang$virtual_dom$VirtualDom_Expando$Constructor,
					_p27,
					false,
					A2(
						_elm_lang$core$List$map,
						_elm_lang$virtual_dom$VirtualDom_Expando$initHelp(false),
						_p26)) : ((_elm_lang$core$Native_Utils.cmp(
					_elm_lang$core$List$length(_p26),
					4) < 1) ? A3(_elm_lang$virtual_dom$VirtualDom_Expando$Constructor, _p27, false, _p26) : expando);
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$init = function (value) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Expando$initHelp,
		true,
		_elm_lang$virtual_dom$Native_Debug.init(value));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$mergeHelp = F2(
	function (old, $new) {
		var _p28 = {ctor: '_Tuple2', _0: old, _1: $new};
		_v12_6:
		do {
			if (_p28.ctor === '_Tuple2') {
				switch (_p28._1.ctor) {
					case 'S':
						return $new;
					case 'Primitive':
						return $new;
					case 'Sequence':
						if (_p28._0.ctor === 'Sequence') {
							return A3(
								_elm_lang$virtual_dom$VirtualDom_Expando$Sequence,
								_p28._1._0,
								_p28._0._1,
								A2(_elm_lang$virtual_dom$VirtualDom_Expando$mergeListHelp, _p28._0._2, _p28._1._2));
						} else {
							break _v12_6;
						}
					case 'Dictionary':
						if (_p28._0.ctor === 'Dictionary') {
							return A2(_elm_lang$virtual_dom$VirtualDom_Expando$Dictionary, _p28._0._0, _p28._1._1);
						} else {
							break _v12_6;
						}
					case 'Record':
						if (_p28._0.ctor === 'Record') {
							return A2(
								_elm_lang$virtual_dom$VirtualDom_Expando$Record,
								_p28._0._0,
								A2(
									_elm_lang$core$Dict$map,
									_elm_lang$virtual_dom$VirtualDom_Expando$mergeDictHelp(_p28._0._1),
									_p28._1._1));
						} else {
							break _v12_6;
						}
					default:
						if (_p28._0.ctor === 'Constructor') {
							return A3(
								_elm_lang$virtual_dom$VirtualDom_Expando$Constructor,
								_p28._1._0,
								_p28._0._1,
								A2(_elm_lang$virtual_dom$VirtualDom_Expando$mergeListHelp, _p28._0._2, _p28._1._2));
						} else {
							break _v12_6;
						}
				}
			} else {
				break _v12_6;
			}
		} while(false);
		return $new;
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$mergeDictHelp = F3(
	function (oldDict, key, value) {
		var _p29 = A2(_elm_lang$core$Dict$get, key, oldDict);
		if (_p29.ctor === 'Nothing') {
			return value;
		} else {
			return A2(_elm_lang$virtual_dom$VirtualDom_Expando$mergeHelp, _p29._0, value);
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$mergeListHelp = F2(
	function (olds, news) {
		var _p30 = {ctor: '_Tuple2', _0: olds, _1: news};
		if (_p30._0.ctor === '[]') {
			return news;
		} else {
			if (_p30._1.ctor === '[]') {
				return news;
			} else {
				return {
					ctor: '::',
					_0: A2(_elm_lang$virtual_dom$VirtualDom_Expando$mergeHelp, _p30._0._0, _p30._1._0),
					_1: A2(_elm_lang$virtual_dom$VirtualDom_Expando$mergeListHelp, _p30._0._1, _p30._1._1)
				};
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$merge = F2(
	function (value, expando) {
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Expando$mergeHelp,
			expando,
			_elm_lang$virtual_dom$Native_Debug.init(value));
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$update = F2(
	function (msg, value) {
		var _p31 = value;
		switch (_p31.ctor) {
			case 'S':
				return _elm_lang$core$Native_Utils.crashCase(
					'VirtualDom.Expando',
					{
						start: {line: 168, column: 3},
						end: {line: 235, column: 50}
					},
					_p31)('No messages for primitives');
			case 'Primitive':
				return _elm_lang$core$Native_Utils.crashCase(
					'VirtualDom.Expando',
					{
						start: {line: 168, column: 3},
						end: {line: 235, column: 50}
					},
					_p31)('No messages for primitives');
			case 'Sequence':
				var _p39 = _p31._2;
				var _p38 = _p31._0;
				var _p37 = _p31._1;
				var _p34 = msg;
				switch (_p34.ctor) {
					case 'Toggle':
						return A3(_elm_lang$virtual_dom$VirtualDom_Expando$Sequence, _p38, !_p37, _p39);
					case 'Index':
						if (_p34._0.ctor === 'None') {
							return A3(
								_elm_lang$virtual_dom$VirtualDom_Expando$Sequence,
								_p38,
								_p37,
								A3(
									_elm_lang$virtual_dom$VirtualDom_Expando$updateIndex,
									_p34._1,
									_elm_lang$virtual_dom$VirtualDom_Expando$update(_p34._2),
									_p39));
						} else {
							return _elm_lang$core$Native_Utils.crashCase(
								'VirtualDom.Expando',
								{
									start: {line: 176, column: 7},
									end: {line: 188, column: 46}
								},
								_p34)('No redirected indexes on sequences');
						}
					default:
						return _elm_lang$core$Native_Utils.crashCase(
							'VirtualDom.Expando',
							{
								start: {line: 176, column: 7},
								end: {line: 188, column: 46}
							},
							_p34)('No field on sequences');
				}
			case 'Dictionary':
				var _p51 = _p31._1;
				var _p50 = _p31._0;
				var _p40 = msg;
				switch (_p40.ctor) {
					case 'Toggle':
						return A2(_elm_lang$virtual_dom$VirtualDom_Expando$Dictionary, !_p50, _p51);
					case 'Index':
						var _p48 = _p40._2;
						var _p47 = _p40._1;
						var _p41 = _p40._0;
						switch (_p41.ctor) {
							case 'None':
								return _elm_lang$core$Native_Utils.crashCase(
									'VirtualDom.Expando',
									{
										start: {line: 196, column: 11},
										end: {line: 206, column: 81}
									},
									_p41)('must have redirect for dictionaries');
							case 'Key':
								return A2(
									_elm_lang$virtual_dom$VirtualDom_Expando$Dictionary,
									_p50,
									A3(
										_elm_lang$virtual_dom$VirtualDom_Expando$updateIndex,
										_p47,
										function (_p43) {
											var _p44 = _p43;
											return {
												ctor: '_Tuple2',
												_0: A2(_elm_lang$virtual_dom$VirtualDom_Expando$update, _p48, _p44._0),
												_1: _p44._1
											};
										},
										_p51));
							default:
								return A2(
									_elm_lang$virtual_dom$VirtualDom_Expando$Dictionary,
									_p50,
									A3(
										_elm_lang$virtual_dom$VirtualDom_Expando$updateIndex,
										_p47,
										function (_p45) {
											var _p46 = _p45;
											return {
												ctor: '_Tuple2',
												_0: _p46._0,
												_1: A2(_elm_lang$virtual_dom$VirtualDom_Expando$update, _p48, _p46._1)
											};
										},
										_p51));
						}
					default:
						return _elm_lang$core$Native_Utils.crashCase(
							'VirtualDom.Expando',
							{
								start: {line: 191, column: 7},
								end: {line: 209, column: 50}
							},
							_p40)('no field for dictionaries');
				}
			case 'Record':
				var _p55 = _p31._1;
				var _p54 = _p31._0;
				var _p52 = msg;
				switch (_p52.ctor) {
					case 'Toggle':
						return A2(_elm_lang$virtual_dom$VirtualDom_Expando$Record, !_p54, _p55);
					case 'Index':
						return _elm_lang$core$Native_Utils.crashCase(
							'VirtualDom.Expando',
							{
								start: {line: 212, column: 7},
								end: {line: 220, column: 77}
							},
							_p52)('No index for records');
					default:
						return A2(
							_elm_lang$virtual_dom$VirtualDom_Expando$Record,
							_p54,
							A3(
								_elm_lang$core$Dict$update,
								_p52._0,
								_elm_lang$virtual_dom$VirtualDom_Expando$updateField(_p52._1),
								_p55));
				}
			default:
				var _p61 = _p31._2;
				var _p60 = _p31._0;
				var _p59 = _p31._1;
				var _p56 = msg;
				switch (_p56.ctor) {
					case 'Toggle':
						return A3(_elm_lang$virtual_dom$VirtualDom_Expando$Constructor, _p60, !_p59, _p61);
					case 'Index':
						if (_p56._0.ctor === 'None') {
							return A3(
								_elm_lang$virtual_dom$VirtualDom_Expando$Constructor,
								_p60,
								_p59,
								A3(
									_elm_lang$virtual_dom$VirtualDom_Expando$updateIndex,
									_p56._1,
									_elm_lang$virtual_dom$VirtualDom_Expando$update(_p56._2),
									_p61));
						} else {
							return _elm_lang$core$Native_Utils.crashCase(
								'VirtualDom.Expando',
								{
									start: {line: 223, column: 7},
									end: {line: 235, column: 50}
								},
								_p56)('No redirected indexes on sequences');
						}
					default:
						return _elm_lang$core$Native_Utils.crashCase(
							'VirtualDom.Expando',
							{
								start: {line: 223, column: 7},
								end: {line: 235, column: 50}
							},
							_p56)('No field for constructors');
				}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$updateField = F2(
	function (msg, maybeExpando) {
		var _p62 = maybeExpando;
		if (_p62.ctor === 'Nothing') {
			return _elm_lang$core$Native_Utils.crashCase(
				'VirtualDom.Expando',
				{
					start: {line: 253, column: 3},
					end: {line: 258, column: 32}
				},
				_p62)('key does not exist');
		} else {
			return _elm_lang$core$Maybe$Just(
				A2(_elm_lang$virtual_dom$VirtualDom_Expando$update, msg, _p62._0));
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$Primitive = function (a) {
	return {ctor: 'Primitive', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Expando$S = function (a) {
	return {ctor: 'S', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Expando$ArraySeq = {ctor: 'ArraySeq'};
var _elm_lang$virtual_dom$VirtualDom_Expando$SetSeq = {ctor: 'SetSeq'};
var _elm_lang$virtual_dom$VirtualDom_Expando$ListSeq = {ctor: 'ListSeq'};
var _elm_lang$virtual_dom$VirtualDom_Expando$Field = F2(
	function (a, b) {
		return {ctor: 'Field', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$Index = F3(
	function (a, b, c) {
		return {ctor: 'Index', _0: a, _1: b, _2: c};
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$Toggle = {ctor: 'Toggle'};
var _elm_lang$virtual_dom$VirtualDom_Expando$Value = {ctor: 'Value'};
var _elm_lang$virtual_dom$VirtualDom_Expando$Key = {ctor: 'Key'};
var _elm_lang$virtual_dom$VirtualDom_Expando$None = {ctor: 'None'};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewConstructorEntry = F2(
	function (index, value) {
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$map,
			A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$None, index),
			A2(
				_elm_lang$virtual_dom$VirtualDom_Expando$view,
				_elm_lang$core$Maybe$Just(
					_elm_lang$core$Basics$toString(index)),
				value));
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$view = F2(
	function (maybeKey, expando) {
		var _p64 = expando;
		switch (_p64.ctor) {
			case 'S':
				return A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(maybeKey),
						_1: {ctor: '[]'}
					},
					A3(
						_elm_lang$virtual_dom$VirtualDom_Expando$lineStarter,
						maybeKey,
						_elm_lang$core$Maybe$Nothing,
						{
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$span,
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Expando$red,
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p64._0),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}));
			case 'Primitive':
				return A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(maybeKey),
						_1: {ctor: '[]'}
					},
					A3(
						_elm_lang$virtual_dom$VirtualDom_Expando$lineStarter,
						maybeKey,
						_elm_lang$core$Maybe$Nothing,
						{
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$span,
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Expando$blue,
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p64._0),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}));
			case 'Sequence':
				return A4(_elm_lang$virtual_dom$VirtualDom_Expando$viewSequence, maybeKey, _p64._0, _p64._1, _p64._2);
			case 'Dictionary':
				return A3(_elm_lang$virtual_dom$VirtualDom_Expando$viewDictionary, maybeKey, _p64._0, _p64._1);
			case 'Record':
				return A3(_elm_lang$virtual_dom$VirtualDom_Expando$viewRecord, maybeKey, _p64._0, _p64._1);
			default:
				return A4(_elm_lang$virtual_dom$VirtualDom_Expando$viewConstructor, maybeKey, _p64._0, _p64._1, _p64._2);
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewConstructor = F4(
	function (maybeKey, maybeName, isClosed, valueList) {
		var _p65 = function () {
			var _p66 = valueList;
			if (_p66.ctor === '[]') {
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Maybe$Nothing,
					_1: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$div,
						{ctor: '[]'},
						{ctor: '[]'})
				};
			} else {
				if (_p66._1.ctor === '[]') {
					var _p67 = _p66._0;
					switch (_p67.ctor) {
						case 'S':
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Maybe$Nothing,
								_1: A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$div,
									{ctor: '[]'},
									{ctor: '[]'})
							};
						case 'Primitive':
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Maybe$Nothing,
								_1: A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$div,
									{ctor: '[]'},
									{ctor: '[]'})
							};
						case 'Sequence':
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Maybe$Just(isClosed),
								_1: isClosed ? A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$div,
									{ctor: '[]'},
									{ctor: '[]'}) : A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$map,
									A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$None, 0),
									_elm_lang$virtual_dom$VirtualDom_Expando$viewSequenceOpen(_p67._2))
							};
						case 'Dictionary':
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Maybe$Just(isClosed),
								_1: isClosed ? A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$div,
									{ctor: '[]'},
									{ctor: '[]'}) : A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$map,
									A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$None, 0),
									_elm_lang$virtual_dom$VirtualDom_Expando$viewDictionaryOpen(_p67._1))
							};
						case 'Record':
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Maybe$Just(isClosed),
								_1: isClosed ? A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$div,
									{ctor: '[]'},
									{ctor: '[]'}) : A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$map,
									A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$None, 0),
									_elm_lang$virtual_dom$VirtualDom_Expando$viewRecordOpen(_p67._1))
							};
						default:
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Maybe$Just(isClosed),
								_1: isClosed ? A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$div,
									{ctor: '[]'},
									{ctor: '[]'}) : A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$map,
									A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$None, 0),
									_elm_lang$virtual_dom$VirtualDom_Expando$viewConstructorOpen(_p67._2))
							};
					}
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Maybe$Just(isClosed),
						_1: isClosed ? A2(
							_elm_lang$virtual_dom$VirtualDom_Helpers$div,
							{ctor: '[]'},
							{ctor: '[]'}) : _elm_lang$virtual_dom$VirtualDom_Expando$viewConstructorOpen(valueList)
					};
				}
			}
		}();
		var maybeIsClosed = _p65._0;
		var openHtml = _p65._1;
		var tinyArgs = A2(
			_elm_lang$core$List$map,
			function (_p68) {
				return _elm_lang$core$Tuple$second(
					_elm_lang$virtual_dom$VirtualDom_Expando$viewExtraTiny(_p68));
			},
			valueList);
		var description = function () {
			var _p69 = {ctor: '_Tuple2', _0: maybeName, _1: tinyArgs};
			if (_p69._0.ctor === 'Nothing') {
				if (_p69._1.ctor === '[]') {
					return {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('()'),
						_1: {ctor: '[]'}
					};
				} else {
					return {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('( '),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$span,
								{ctor: '[]'},
								_p69._1._0),
							_1: A3(
								_elm_lang$core$List$foldr,
								F2(
									function (args, rest) {
										return {
											ctor: '::',
											_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(', '),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$virtual_dom$VirtualDom_Helpers$span,
													{ctor: '[]'},
													args),
												_1: rest
											}
										};
									}),
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' )'),
									_1: {ctor: '[]'}
								},
								_p69._1._1)
						}
					};
				}
			} else {
				if (_p69._1.ctor === '[]') {
					return {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p69._0._0),
						_1: {ctor: '[]'}
					};
				} else {
					return {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
							A2(_elm_lang$core$Basics_ops['++'], _p69._0._0, ' ')),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$span,
								{ctor: '[]'},
								_p69._1._0),
							_1: A3(
								_elm_lang$core$List$foldr,
								F2(
									function (args, rest) {
										return {
											ctor: '::',
											_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' '),
											_1: {
												ctor: '::',
												_0: A2(
													_elm_lang$virtual_dom$VirtualDom_Helpers$span,
													{ctor: '[]'},
													args),
												_1: rest
											}
										};
									}),
								{ctor: '[]'},
								_p69._1._1)
						}
					};
				}
			}
		}();
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(maybeKey),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Expando$Toggle),
						_1: {ctor: '[]'}
					},
					A3(_elm_lang$virtual_dom$VirtualDom_Expando$lineStarter, maybeKey, maybeIsClosed, description)),
				_1: {
					ctor: '::',
					_0: openHtml,
					_1: {ctor: '[]'}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewConstructorOpen = function (valueList) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{ctor: '[]'},
		A2(_elm_lang$core$List$indexedMap, _elm_lang$virtual_dom$VirtualDom_Expando$viewConstructorEntry, valueList));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewDictionaryOpen = function (keyValuePairs) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{ctor: '[]'},
		A2(_elm_lang$core$List$indexedMap, _elm_lang$virtual_dom$VirtualDom_Expando$viewDictionaryEntry, keyValuePairs));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewDictionaryEntry = F2(
	function (index, _p70) {
		var _p71 = _p70;
		var _p74 = _p71._1;
		var _p73 = _p71._0;
		var _p72 = _p73;
		switch (_p72.ctor) {
			case 'S':
				return A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$map,
					A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$Value, index),
					A2(
						_elm_lang$virtual_dom$VirtualDom_Expando$view,
						_elm_lang$core$Maybe$Just(_p72._0),
						_p74));
			case 'Primitive':
				return A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$map,
					A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$Value, index),
					A2(
						_elm_lang$virtual_dom$VirtualDom_Expando$view,
						_elm_lang$core$Maybe$Just(_p72._0),
						_p74));
			default:
				return A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$virtual_dom$VirtualDom_Helpers$map,
							A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$Key, index),
							A2(
								_elm_lang$virtual_dom$VirtualDom_Expando$view,
								_elm_lang$core$Maybe$Just('key'),
								_p73)),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$map,
								A2(_elm_lang$virtual_dom$VirtualDom_Expando$Index, _elm_lang$virtual_dom$VirtualDom_Expando$Value, index),
								A2(
									_elm_lang$virtual_dom$VirtualDom_Expando$view,
									_elm_lang$core$Maybe$Just('value'),
									_p74)),
							_1: {ctor: '[]'}
						}
					});
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewRecordOpen = function (record) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{ctor: '[]'},
		A2(
			_elm_lang$core$List$map,
			_elm_lang$virtual_dom$VirtualDom_Expando$viewRecordEntry,
			_elm_lang$core$Dict$toList(record)));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewRecordEntry = function (_p75) {
	var _p76 = _p75;
	var _p77 = _p76._0;
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$map,
		_elm_lang$virtual_dom$VirtualDom_Expando$Field(_p77),
		A2(
			_elm_lang$virtual_dom$VirtualDom_Expando$view,
			_elm_lang$core$Maybe$Just(_p77),
			_p76._1));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewSequenceOpen = function (values) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{ctor: '[]'},
		A2(_elm_lang$core$List$indexedMap, _elm_lang$virtual_dom$VirtualDom_Expando$viewConstructorEntry, values));
};
var _elm_lang$virtual_dom$VirtualDom_Expando$viewDictionary = F3(
	function (maybeKey, isClosed, keyValuePairs) {
		var starter = A2(
			_elm_lang$core$Basics_ops['++'],
			'Dict(',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Basics$toString(
					_elm_lang$core$List$length(keyValuePairs)),
				')'));
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(maybeKey),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Expando$Toggle),
						_1: {ctor: '[]'}
					},
					A3(
						_elm_lang$virtual_dom$VirtualDom_Expando$lineStarter,
						maybeKey,
						_elm_lang$core$Maybe$Just(isClosed),
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(starter),
							_1: {ctor: '[]'}
						})),
				_1: {
					ctor: '::',
					_0: isClosed ? _elm_lang$virtual_dom$VirtualDom_Helpers$text('') : _elm_lang$virtual_dom$VirtualDom_Expando$viewDictionaryOpen(keyValuePairs),
					_1: {ctor: '[]'}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewRecord = F3(
	function (maybeKey, isClosed, record) {
		var _p78 = isClosed ? {
			ctor: '_Tuple3',
			_0: _elm_lang$core$Tuple$second(
				_elm_lang$virtual_dom$VirtualDom_Expando$viewTinyRecord(record)),
			_1: _elm_lang$virtual_dom$VirtualDom_Helpers$text(''),
			_2: _elm_lang$virtual_dom$VirtualDom_Helpers$text('')
		} : {
			ctor: '_Tuple3',
			_0: {
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('{'),
				_1: {ctor: '[]'}
			},
			_1: _elm_lang$virtual_dom$VirtualDom_Expando$viewRecordOpen(record),
			_2: A2(
				_elm_lang$virtual_dom$VirtualDom_Helpers$div,
				{
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(
						_elm_lang$core$Maybe$Just(
							{ctor: '_Tuple0'})),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('}'),
					_1: {ctor: '[]'}
				})
		};
		var start = _p78._0;
		var middle = _p78._1;
		var end = _p78._2;
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(maybeKey),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Expando$Toggle),
						_1: {ctor: '[]'}
					},
					A3(
						_elm_lang$virtual_dom$VirtualDom_Expando$lineStarter,
						maybeKey,
						_elm_lang$core$Maybe$Just(isClosed),
						start)),
				_1: {
					ctor: '::',
					_0: middle,
					_1: {
						ctor: '::',
						_0: end,
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Expando$viewSequence = F4(
	function (maybeKey, seqType, isClosed, valueList) {
		var starter = A2(
			_elm_lang$virtual_dom$VirtualDom_Expando$seqTypeToString,
			_elm_lang$core$List$length(valueList),
			seqType);
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Expando$leftPad(maybeKey),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Expando$Toggle),
						_1: {ctor: '[]'}
					},
					A3(
						_elm_lang$virtual_dom$VirtualDom_Expando$lineStarter,
						maybeKey,
						_elm_lang$core$Maybe$Just(isClosed),
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(starter),
							_1: {ctor: '[]'}
						})),
				_1: {
					ctor: '::',
					_0: isClosed ? _elm_lang$virtual_dom$VirtualDom_Helpers$text('') : _elm_lang$virtual_dom$VirtualDom_Expando$viewSequenceOpen(valueList),
					_1: {ctor: '[]'}
				}
			});
	});

var _elm_lang$virtual_dom$VirtualDom_Report$some = function (list) {
	return !_elm_lang$core$List$isEmpty(list);
};
var _elm_lang$virtual_dom$VirtualDom_Report$TagChanges = F4(
	function (a, b, c, d) {
		return {removed: a, changed: b, added: c, argsMatch: d};
	});
var _elm_lang$virtual_dom$VirtualDom_Report$emptyTagChanges = function (argsMatch) {
	return A4(
		_elm_lang$virtual_dom$VirtualDom_Report$TagChanges,
		{ctor: '[]'},
		{ctor: '[]'},
		{ctor: '[]'},
		argsMatch);
};
var _elm_lang$virtual_dom$VirtualDom_Report$hasTagChanges = function (tagChanges) {
	return _elm_lang$core$Native_Utils.eq(
		tagChanges,
		A4(
			_elm_lang$virtual_dom$VirtualDom_Report$TagChanges,
			{ctor: '[]'},
			{ctor: '[]'},
			{ctor: '[]'},
			true));
};
var _elm_lang$virtual_dom$VirtualDom_Report$SomethingChanged = function (a) {
	return {ctor: 'SomethingChanged', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Report$MessageChanged = F2(
	function (a, b) {
		return {ctor: 'MessageChanged', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Report$VersionChanged = F2(
	function (a, b) {
		return {ctor: 'VersionChanged', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Report$CorruptHistory = {ctor: 'CorruptHistory'};
var _elm_lang$virtual_dom$VirtualDom_Report$UnionChange = F2(
	function (a, b) {
		return {ctor: 'UnionChange', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Report$AliasChange = function (a) {
	return {ctor: 'AliasChange', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Report$Fine = {ctor: 'Fine'};
var _elm_lang$virtual_dom$VirtualDom_Report$Risky = {ctor: 'Risky'};
var _elm_lang$virtual_dom$VirtualDom_Report$Impossible = {ctor: 'Impossible'};
var _elm_lang$virtual_dom$VirtualDom_Report$worstCase = F2(
	function (status, statusList) {
		worstCase:
		while (true) {
			var _p0 = statusList;
			if (_p0.ctor === '[]') {
				return status;
			} else {
				switch (_p0._0.ctor) {
					case 'Impossible':
						return _elm_lang$virtual_dom$VirtualDom_Report$Impossible;
					case 'Risky':
						var _v1 = _elm_lang$virtual_dom$VirtualDom_Report$Risky,
							_v2 = _p0._1;
						status = _v1;
						statusList = _v2;
						continue worstCase;
					default:
						var _v3 = status,
							_v4 = _p0._1;
						status = _v3;
						statusList = _v4;
						continue worstCase;
				}
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Report$evaluateChange = function (change) {
	var _p1 = change;
	if (_p1.ctor === 'AliasChange') {
		return _elm_lang$virtual_dom$VirtualDom_Report$Impossible;
	} else {
		return ((!_p1._1.argsMatch) || (_elm_lang$virtual_dom$VirtualDom_Report$some(_p1._1.changed) || _elm_lang$virtual_dom$VirtualDom_Report$some(_p1._1.removed))) ? _elm_lang$virtual_dom$VirtualDom_Report$Impossible : (_elm_lang$virtual_dom$VirtualDom_Report$some(_p1._1.added) ? _elm_lang$virtual_dom$VirtualDom_Report$Risky : _elm_lang$virtual_dom$VirtualDom_Report$Fine);
	}
};
var _elm_lang$virtual_dom$VirtualDom_Report$evaluate = function (report) {
	var _p2 = report;
	switch (_p2.ctor) {
		case 'CorruptHistory':
			return _elm_lang$virtual_dom$VirtualDom_Report$Impossible;
		case 'VersionChanged':
			return _elm_lang$virtual_dom$VirtualDom_Report$Impossible;
		case 'MessageChanged':
			return _elm_lang$virtual_dom$VirtualDom_Report$Impossible;
		default:
			return A2(
				_elm_lang$virtual_dom$VirtualDom_Report$worstCase,
				_elm_lang$virtual_dom$VirtualDom_Report$Fine,
				A2(_elm_lang$core$List$map, _elm_lang$virtual_dom$VirtualDom_Report$evaluateChange, _p2._0));
	}
};

var _elm_lang$virtual_dom$VirtualDom_Metadata$encodeDict = F2(
	function (f, dict) {
		return _elm_lang$core$Json_Encode$object(
			_elm_lang$core$Dict$toList(
				A2(
					_elm_lang$core$Dict$map,
					F2(
						function (key, value) {
							return f(value);
						}),
					dict)));
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$encodeUnion = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'args',
				_1: _elm_lang$core$Json_Encode$list(
					A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$string, _p1.args))
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'tags',
					_1: A2(
						_elm_lang$virtual_dom$VirtualDom_Metadata$encodeDict,
						function (_p2) {
							return _elm_lang$core$Json_Encode$list(
								A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$string, _p2));
						},
						_p1.tags)
				},
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$encodeAlias = function (_p3) {
	var _p4 = _p3;
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'args',
				_1: _elm_lang$core$Json_Encode$list(
					A2(_elm_lang$core$List$map, _elm_lang$core$Json_Encode$string, _p4.args))
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'type',
					_1: _elm_lang$core$Json_Encode$string(_p4.tipe)
				},
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$encodeTypes = function (_p5) {
	var _p6 = _p5;
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'message',
				_1: _elm_lang$core$Json_Encode$string(_p6.message)
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'aliases',
					_1: A2(_elm_lang$virtual_dom$VirtualDom_Metadata$encodeDict, _elm_lang$virtual_dom$VirtualDom_Metadata$encodeAlias, _p6.aliases)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'unions',
						_1: A2(_elm_lang$virtual_dom$VirtualDom_Metadata$encodeDict, _elm_lang$virtual_dom$VirtualDom_Metadata$encodeUnion, _p6.unions)
					},
					_1: {ctor: '[]'}
				}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$encodeVersions = function (_p7) {
	var _p8 = _p7;
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'elm',
				_1: _elm_lang$core$Json_Encode$string(_p8.elm)
			},
			_1: {ctor: '[]'}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$encode = function (_p9) {
	var _p10 = _p9;
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'versions',
				_1: _elm_lang$virtual_dom$VirtualDom_Metadata$encodeVersions(_p10.versions)
			},
			_1: {
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'types',
					_1: _elm_lang$virtual_dom$VirtualDom_Metadata$encodeTypes(_p10.types)
				},
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$checkTag = F4(
	function (tag, old, $new, changes) {
		return _elm_lang$core$Native_Utils.eq(old, $new) ? changes : _elm_lang$core$Native_Utils.update(
			changes,
			{
				changed: {ctor: '::', _0: tag, _1: changes.changed}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$addTag = F3(
	function (tag, _p11, changes) {
		return _elm_lang$core$Native_Utils.update(
			changes,
			{
				added: {ctor: '::', _0: tag, _1: changes.added}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$removeTag = F3(
	function (tag, _p12, changes) {
		return _elm_lang$core$Native_Utils.update(
			changes,
			{
				removed: {ctor: '::', _0: tag, _1: changes.removed}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$checkUnion = F4(
	function (name, old, $new, changes) {
		var tagChanges = A6(
			_elm_lang$core$Dict$merge,
			_elm_lang$virtual_dom$VirtualDom_Metadata$removeTag,
			_elm_lang$virtual_dom$VirtualDom_Metadata$checkTag,
			_elm_lang$virtual_dom$VirtualDom_Metadata$addTag,
			old.tags,
			$new.tags,
			_elm_lang$virtual_dom$VirtualDom_Report$emptyTagChanges(
				_elm_lang$core$Native_Utils.eq(old.args, $new.args)));
		return _elm_lang$virtual_dom$VirtualDom_Report$hasTagChanges(tagChanges) ? changes : {
			ctor: '::',
			_0: A2(_elm_lang$virtual_dom$VirtualDom_Report$UnionChange, name, tagChanges),
			_1: changes
		};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$checkAlias = F4(
	function (name, old, $new, changes) {
		return (_elm_lang$core$Native_Utils.eq(old.tipe, $new.tipe) && _elm_lang$core$Native_Utils.eq(old.args, $new.args)) ? changes : {
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Report$AliasChange(name),
			_1: changes
		};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$ignore = F3(
	function (key, value, report) {
		return report;
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$checkTypes = F2(
	function (old, $new) {
		return (!_elm_lang$core$Native_Utils.eq(old.message, $new.message)) ? A2(_elm_lang$virtual_dom$VirtualDom_Report$MessageChanged, old.message, $new.message) : _elm_lang$virtual_dom$VirtualDom_Report$SomethingChanged(
			A6(
				_elm_lang$core$Dict$merge,
				_elm_lang$virtual_dom$VirtualDom_Metadata$ignore,
				_elm_lang$virtual_dom$VirtualDom_Metadata$checkUnion,
				_elm_lang$virtual_dom$VirtualDom_Metadata$ignore,
				old.unions,
				$new.unions,
				A6(
					_elm_lang$core$Dict$merge,
					_elm_lang$virtual_dom$VirtualDom_Metadata$ignore,
					_elm_lang$virtual_dom$VirtualDom_Metadata$checkAlias,
					_elm_lang$virtual_dom$VirtualDom_Metadata$ignore,
					old.aliases,
					$new.aliases,
					{ctor: '[]'})));
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$check = F2(
	function (old, $new) {
		return (!_elm_lang$core$Native_Utils.eq(old.versions.elm, $new.versions.elm)) ? A2(_elm_lang$virtual_dom$VirtualDom_Report$VersionChanged, old.versions.elm, $new.versions.elm) : A2(_elm_lang$virtual_dom$VirtualDom_Metadata$checkTypes, old.types, $new.types);
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$hasProblem = F2(
	function (tipe, _p13) {
		var _p14 = _p13;
		return A2(_elm_lang$core$String$contains, _p14._1, tipe) ? _elm_lang$core$Maybe$Just(_p14._0) : _elm_lang$core$Maybe$Nothing;
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$Metadata = F2(
	function (a, b) {
		return {versions: a, types: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$Versions = function (a) {
	return {elm: a};
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$decodeVersions = A2(
	_elm_lang$core$Json_Decode$map,
	_elm_lang$virtual_dom$VirtualDom_Metadata$Versions,
	A2(_elm_lang$core$Json_Decode$field, 'elm', _elm_lang$core$Json_Decode$string));
var _elm_lang$virtual_dom$VirtualDom_Metadata$Types = F3(
	function (a, b, c) {
		return {message: a, aliases: b, unions: c};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$Alias = F2(
	function (a, b) {
		return {args: a, tipe: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$decodeAlias = A3(
	_elm_lang$core$Json_Decode$map2,
	_elm_lang$virtual_dom$VirtualDom_Metadata$Alias,
	A2(
		_elm_lang$core$Json_Decode$field,
		'args',
		_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$string)),
	A2(_elm_lang$core$Json_Decode$field, 'type', _elm_lang$core$Json_Decode$string));
var _elm_lang$virtual_dom$VirtualDom_Metadata$Union = F2(
	function (a, b) {
		return {args: a, tags: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$decodeUnion = A3(
	_elm_lang$core$Json_Decode$map2,
	_elm_lang$virtual_dom$VirtualDom_Metadata$Union,
	A2(
		_elm_lang$core$Json_Decode$field,
		'args',
		_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$string)),
	A2(
		_elm_lang$core$Json_Decode$field,
		'tags',
		_elm_lang$core$Json_Decode$dict(
			_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$string))));
var _elm_lang$virtual_dom$VirtualDom_Metadata$decodeTypes = A4(
	_elm_lang$core$Json_Decode$map3,
	_elm_lang$virtual_dom$VirtualDom_Metadata$Types,
	A2(_elm_lang$core$Json_Decode$field, 'message', _elm_lang$core$Json_Decode$string),
	A2(
		_elm_lang$core$Json_Decode$field,
		'aliases',
		_elm_lang$core$Json_Decode$dict(_elm_lang$virtual_dom$VirtualDom_Metadata$decodeAlias)),
	A2(
		_elm_lang$core$Json_Decode$field,
		'unions',
		_elm_lang$core$Json_Decode$dict(_elm_lang$virtual_dom$VirtualDom_Metadata$decodeUnion)));
var _elm_lang$virtual_dom$VirtualDom_Metadata$decoder = A3(
	_elm_lang$core$Json_Decode$map2,
	_elm_lang$virtual_dom$VirtualDom_Metadata$Metadata,
	A2(_elm_lang$core$Json_Decode$field, 'versions', _elm_lang$virtual_dom$VirtualDom_Metadata$decodeVersions),
	A2(_elm_lang$core$Json_Decode$field, 'types', _elm_lang$virtual_dom$VirtualDom_Metadata$decodeTypes));
var _elm_lang$virtual_dom$VirtualDom_Metadata$Error = F2(
	function (a, b) {
		return {message: a, problems: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$ProblemType = F2(
	function (a, b) {
		return {name: a, problems: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$VirtualDom = {ctor: 'VirtualDom'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Program = {ctor: 'Program'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Request = {ctor: 'Request'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Socket = {ctor: 'Socket'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Process = {ctor: 'Process'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Task = {ctor: 'Task'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Decoder = {ctor: 'Decoder'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$Function = {ctor: 'Function'};
var _elm_lang$virtual_dom$VirtualDom_Metadata$problemTable = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Function, _1: '->'},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Decoder, _1: 'Json.Decode.Decoder'},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Task, _1: 'Task.Task'},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Process, _1: 'Process.Id'},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Socket, _1: 'WebSocket.LowLevel.WebSocket'},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Request, _1: 'Http.Request'},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$Program, _1: 'Platform.Program'},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$VirtualDom, _1: 'VirtualDom.Node'},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: _elm_lang$virtual_dom$VirtualDom_Metadata$VirtualDom, _1: 'VirtualDom.Attribute'},
									_1: {ctor: '[]'}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$findProblems = function (tipe) {
	return A2(
		_elm_lang$core$List$filterMap,
		_elm_lang$virtual_dom$VirtualDom_Metadata$hasProblem(tipe),
		_elm_lang$virtual_dom$VirtualDom_Metadata$problemTable);
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$collectBadAliases = F3(
	function (name, _p15, list) {
		var _p16 = _p15;
		var _p17 = _elm_lang$virtual_dom$VirtualDom_Metadata$findProblems(_p16.tipe);
		if (_p17.ctor === '[]') {
			return list;
		} else {
			return {
				ctor: '::',
				_0: A2(_elm_lang$virtual_dom$VirtualDom_Metadata$ProblemType, name, _p17),
				_1: list
			};
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$collectBadUnions = F3(
	function (name, _p18, list) {
		var _p19 = _p18;
		var _p20 = A2(
			_elm_lang$core$List$concatMap,
			_elm_lang$virtual_dom$VirtualDom_Metadata$findProblems,
			_elm_lang$core$List$concat(
				_elm_lang$core$Dict$values(_p19.tags)));
		if (_p20.ctor === '[]') {
			return list;
		} else {
			return {
				ctor: '::',
				_0: A2(_elm_lang$virtual_dom$VirtualDom_Metadata$ProblemType, name, _p20),
				_1: list
			};
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Metadata$isPortable = function (_p21) {
	var _p22 = _p21;
	var _p24 = _p22.types;
	var badAliases = A3(
		_elm_lang$core$Dict$foldl,
		_elm_lang$virtual_dom$VirtualDom_Metadata$collectBadAliases,
		{ctor: '[]'},
		_p24.aliases);
	var _p23 = A3(_elm_lang$core$Dict$foldl, _elm_lang$virtual_dom$VirtualDom_Metadata$collectBadUnions, badAliases, _p24.unions);
	if (_p23.ctor === '[]') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		return _elm_lang$core$Maybe$Just(
			A2(_elm_lang$virtual_dom$VirtualDom_Metadata$Error, _p24.message, _p23));
	}
};
var _elm_lang$virtual_dom$VirtualDom_Metadata$decode = function (value) {
	var _p25 = A2(_elm_lang$core$Json_Decode$decodeValue, _elm_lang$virtual_dom$VirtualDom_Metadata$decoder, value);
	if (_p25.ctor === 'Err') {
		return _elm_lang$core$Native_Utils.crashCase(
			'VirtualDom.Metadata',
			{
				start: {line: 229, column: 3},
				end: {line: 239, column: 20}
			},
			_p25)('Compiler is generating bad metadata. Report this at <https://github.com/elm-lang/virtual-dom/issues>.');
	} else {
		var _p28 = _p25._0;
		var _p27 = _elm_lang$virtual_dom$VirtualDom_Metadata$isPortable(_p28);
		if (_p27.ctor === 'Nothing') {
			return _elm_lang$core$Result$Ok(_p28);
		} else {
			return _elm_lang$core$Result$Err(_p27._0);
		}
	}
};

var _elm_lang$virtual_dom$VirtualDom_History$viewMessage = F3(
	function (currentIndex, index, msg) {
		var messageName = _elm_lang$virtual_dom$Native_Debug.messageToString(msg);
		var className = _elm_lang$core$Native_Utils.eq(currentIndex, index) ? 'messages-entry messages-entry-selected' : 'messages-entry';
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class(className),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$on,
						'click',
						_elm_lang$core$Json_Decode$succeed(index)),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$span,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('messages-entry-content'),
						_1: {
							ctor: '::',
							_0: A2(_elm_lang$virtual_dom$VirtualDom_Helpers$attribute, 'title', messageName),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(messageName),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$span,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('messages-entry-index'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
								_elm_lang$core$Basics$toString(index)),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_History$consMsg = F3(
	function (currentIndex, msg, _p0) {
		var _p1 = _p0;
		var _p2 = _p1._0;
		return {
			ctor: '_Tuple2',
			_0: _p2 - 1,
			_1: {
				ctor: '::',
				_0: A4(_elm_lang$virtual_dom$VirtualDom_Helpers$lazy3, _elm_lang$virtual_dom$VirtualDom_History$viewMessage, currentIndex, _p2, msg),
				_1: _p1._1
			}
		};
	});
var _elm_lang$virtual_dom$VirtualDom_History$viewSnapshot = F3(
	function (currentIndex, index, _p3) {
		var _p4 = _p3;
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{ctor: '[]'},
			_elm_lang$core$Tuple$second(
				A3(
					_elm_lang$core$Array$foldl,
					_elm_lang$virtual_dom$VirtualDom_History$consMsg(currentIndex),
					{
						ctor: '_Tuple2',
						_0: index - 1,
						_1: {ctor: '[]'}
					},
					_p4.messages)));
	});
var _elm_lang$virtual_dom$VirtualDom_History$undone = function (getResult) {
	var _p5 = getResult;
	if (_p5.ctor === 'Done') {
		return {ctor: '_Tuple2', _0: _p5._1, _1: _p5._0};
	} else {
		return _elm_lang$core$Native_Utils.crashCase(
			'VirtualDom.History',
			{
				start: {line: 195, column: 3},
				end: {line: 200, column: 39}
			},
			_p5)('Bug in History.get');
	}
};
var _elm_lang$virtual_dom$VirtualDom_History$elmToJs = _elm_lang$virtual_dom$Native_Debug.unsafeCoerce;
var _elm_lang$virtual_dom$VirtualDom_History$encodeHelp = F2(
	function (snapshot, allMessages) {
		return A3(
			_elm_lang$core$Array$foldl,
			F2(
				function (elm, msgs) {
					return {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_History$elmToJs(elm),
						_1: msgs
					};
				}),
			allMessages,
			snapshot.messages);
	});
var _elm_lang$virtual_dom$VirtualDom_History$encode = function (_p7) {
	var _p8 = _p7;
	var recentJson = A2(
		_elm_lang$core$List$map,
		_elm_lang$virtual_dom$VirtualDom_History$elmToJs,
		_elm_lang$core$List$reverse(_p8.recent.messages));
	return _elm_lang$core$Json_Encode$list(
		A3(_elm_lang$core$Array$foldr, _elm_lang$virtual_dom$VirtualDom_History$encodeHelp, recentJson, _p8.snapshots));
};
var _elm_lang$virtual_dom$VirtualDom_History$jsToElm = _elm_lang$virtual_dom$Native_Debug.unsafeCoerce;
var _elm_lang$virtual_dom$VirtualDom_History$initialModel = function (_p9) {
	var _p10 = _p9;
	var _p11 = A2(_elm_lang$core$Array$get, 0, _p10.snapshots);
	if (_p11.ctor === 'Just') {
		return _p11._0.model;
	} else {
		return _p10.recent.model;
	}
};
var _elm_lang$virtual_dom$VirtualDom_History$size = function (history) {
	return history.numMessages;
};
var _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize = 64;
var _elm_lang$virtual_dom$VirtualDom_History$consSnapshot = F3(
	function (currentIndex, snapshot, _p12) {
		var _p13 = _p12;
		var _p14 = _p13._0;
		var nextIndex = _p14 - _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize;
		var currentIndexHelp = ((_elm_lang$core$Native_Utils.cmp(nextIndex, currentIndex) < 1) && (_elm_lang$core$Native_Utils.cmp(currentIndex, _p14) < 0)) ? currentIndex : -1;
		return {
			ctor: '_Tuple2',
			_0: _p14 - _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize,
			_1: {
				ctor: '::',
				_0: A4(_elm_lang$virtual_dom$VirtualDom_Helpers$lazy3, _elm_lang$virtual_dom$VirtualDom_History$viewSnapshot, currentIndexHelp, _p14, snapshot),
				_1: _p13._1
			}
		};
	});
var _elm_lang$virtual_dom$VirtualDom_History$viewSnapshots = F2(
	function (currentIndex, snapshots) {
		var highIndex = _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize * _elm_lang$core$Array$length(snapshots);
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{ctor: '[]'},
			_elm_lang$core$Tuple$second(
				A3(
					_elm_lang$core$Array$foldr,
					_elm_lang$virtual_dom$VirtualDom_History$consSnapshot(currentIndex),
					{
						ctor: '_Tuple2',
						_0: highIndex,
						_1: {ctor: '[]'}
					},
					snapshots)));
	});
var _elm_lang$virtual_dom$VirtualDom_History$view = F2(
	function (maybeIndex, _p15) {
		var _p16 = _p15;
		var _p17 = function () {
			var _p18 = maybeIndex;
			if (_p18.ctor === 'Nothing') {
				return {ctor: '_Tuple2', _0: -1, _1: 'debugger-sidebar-messages'};
			} else {
				return {ctor: '_Tuple2', _0: _p18._0, _1: 'debugger-sidebar-messages-paused'};
			}
		}();
		var index = _p17._0;
		var className = _p17._1;
		var oldStuff = A3(_elm_lang$virtual_dom$VirtualDom_Helpers$lazy2, _elm_lang$virtual_dom$VirtualDom_History$viewSnapshots, index, _p16.snapshots);
		var newStuff = _elm_lang$core$Tuple$second(
			A3(
				_elm_lang$core$List$foldl,
				_elm_lang$virtual_dom$VirtualDom_History$consMsg(index),
				{
					ctor: '_Tuple2',
					_0: _p16.numMessages - 1,
					_1: {ctor: '[]'}
				},
				_p16.recent.messages));
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class(className),
				_1: {ctor: '[]'}
			},
			{ctor: '::', _0: oldStuff, _1: newStuff});
	});
var _elm_lang$virtual_dom$VirtualDom_History$History = F3(
	function (a, b, c) {
		return {snapshots: a, recent: b, numMessages: c};
	});
var _elm_lang$virtual_dom$VirtualDom_History$RecentHistory = F3(
	function (a, b, c) {
		return {model: a, messages: b, numMessages: c};
	});
var _elm_lang$virtual_dom$VirtualDom_History$empty = function (model) {
	return A3(
		_elm_lang$virtual_dom$VirtualDom_History$History,
		_elm_lang$core$Array$empty,
		A3(
			_elm_lang$virtual_dom$VirtualDom_History$RecentHistory,
			model,
			{ctor: '[]'},
			0),
		0);
};
var _elm_lang$virtual_dom$VirtualDom_History$Snapshot = F2(
	function (a, b) {
		return {model: a, messages: b};
	});
var _elm_lang$virtual_dom$VirtualDom_History$addRecent = F3(
	function (msg, newModel, _p19) {
		var _p20 = _p19;
		var _p23 = _p20.numMessages;
		var _p22 = _p20.model;
		var _p21 = _p20.messages;
		return _elm_lang$core$Native_Utils.eq(_p23, _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize) ? {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Maybe$Just(
				A2(
					_elm_lang$virtual_dom$VirtualDom_History$Snapshot,
					_p22,
					_elm_lang$core$Array$fromList(_p21))),
			_1: A3(
				_elm_lang$virtual_dom$VirtualDom_History$RecentHistory,
				newModel,
				{
					ctor: '::',
					_0: msg,
					_1: {ctor: '[]'}
				},
				1)
		} : {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Maybe$Nothing,
			_1: A3(
				_elm_lang$virtual_dom$VirtualDom_History$RecentHistory,
				_p22,
				{ctor: '::', _0: msg, _1: _p21},
				_p23 + 1)
		};
	});
var _elm_lang$virtual_dom$VirtualDom_History$add = F3(
	function (msg, model, _p24) {
		var _p25 = _p24;
		var _p28 = _p25.snapshots;
		var _p27 = _p25.numMessages;
		var _p26 = A3(_elm_lang$virtual_dom$VirtualDom_History$addRecent, msg, model, _p25.recent);
		if (_p26._0.ctor === 'Just') {
			return A3(
				_elm_lang$virtual_dom$VirtualDom_History$History,
				A2(_elm_lang$core$Array$push, _p26._0._0, _p28),
				_p26._1,
				_p27 + 1);
		} else {
			return A3(_elm_lang$virtual_dom$VirtualDom_History$History, _p28, _p26._1, _p27 + 1);
		}
	});
var _elm_lang$virtual_dom$VirtualDom_History$decoder = F2(
	function (initialModel, update) {
		var addMessage = F2(
			function (rawMsg, _p29) {
				var _p30 = _p29;
				var _p31 = _p30._0;
				var msg = _elm_lang$virtual_dom$VirtualDom_History$jsToElm(rawMsg);
				return {
					ctor: '_Tuple2',
					_0: A2(update, msg, _p31),
					_1: A3(_elm_lang$virtual_dom$VirtualDom_History$add, msg, _p31, _p30._1)
				};
			});
		var updateModel = function (rawMsgs) {
			return A3(
				_elm_lang$core$List$foldl,
				addMessage,
				{
					ctor: '_Tuple2',
					_0: initialModel,
					_1: _elm_lang$virtual_dom$VirtualDom_History$empty(initialModel)
				},
				rawMsgs);
		};
		return A2(
			_elm_lang$core$Json_Decode$map,
			updateModel,
			_elm_lang$core$Json_Decode$list(_elm_lang$core$Json_Decode$value));
	});
var _elm_lang$virtual_dom$VirtualDom_History$Done = F2(
	function (a, b) {
		return {ctor: 'Done', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_History$Stepping = F2(
	function (a, b) {
		return {ctor: 'Stepping', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_History$getHelp = F3(
	function (update, msg, getResult) {
		var _p32 = getResult;
		if (_p32.ctor === 'Done') {
			return getResult;
		} else {
			var _p34 = _p32._0;
			var _p33 = _p32._1;
			return _elm_lang$core$Native_Utils.eq(_p34, 0) ? A2(
				_elm_lang$virtual_dom$VirtualDom_History$Done,
				msg,
				_elm_lang$core$Tuple$first(
					A2(update, msg, _p33))) : A2(
				_elm_lang$virtual_dom$VirtualDom_History$Stepping,
				_p34 - 1,
				_elm_lang$core$Tuple$first(
					A2(update, msg, _p33)));
		}
	});
var _elm_lang$virtual_dom$VirtualDom_History$get = F3(
	function (update, index, _p35) {
		var _p36 = _p35;
		var _p39 = _p36.recent;
		var snapshotMax = _p36.numMessages - _p39.numMessages;
		if (_elm_lang$core$Native_Utils.cmp(index, snapshotMax) > -1) {
			return _elm_lang$virtual_dom$VirtualDom_History$undone(
				A3(
					_elm_lang$core$List$foldr,
					_elm_lang$virtual_dom$VirtualDom_History$getHelp(update),
					A2(_elm_lang$virtual_dom$VirtualDom_History$Stepping, index - snapshotMax, _p39.model),
					_p39.messages));
		} else {
			var _p37 = A2(_elm_lang$core$Array$get, (index / _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize) | 0, _p36.snapshots);
			if (_p37.ctor === 'Nothing') {
				return _elm_lang$core$Native_Utils.crashCase(
					'VirtualDom.History',
					{
						start: {line: 165, column: 7},
						end: {line: 171, column: 95}
					},
					_p37)('UI should only let you ask for real indexes!');
			} else {
				return _elm_lang$virtual_dom$VirtualDom_History$undone(
					A3(
						_elm_lang$core$Array$foldr,
						_elm_lang$virtual_dom$VirtualDom_History$getHelp(update),
						A2(
							_elm_lang$virtual_dom$VirtualDom_History$Stepping,
							A2(_elm_lang$core$Basics$rem, index, _elm_lang$virtual_dom$VirtualDom_History$maxSnapshotSize),
							_p37._0.model),
						_p37._0.messages));
			}
		}
	});

var _elm_lang$virtual_dom$VirtualDom_Overlay$styles = A3(
	_elm_lang$virtual_dom$VirtualDom_Helpers$node,
	'style',
	{ctor: '[]'},
	{
		ctor: '::',
		_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('\n\n.elm-overlay {\n  position: fixed;\n  top: 0;\n  left: 0;\n  width: 100%;\n  height: 100%;\n  color: white;\n  pointer-events: none;\n  font-family: \'Trebuchet MS\', \'Lucida Grande\', \'Bitstream Vera Sans\', \'Helvetica Neue\', sans-serif;\n}\n\n.elm-overlay-resume {\n  width: 100%;\n  height: 100%;\n  cursor: pointer;\n  text-align: center;\n  pointer-events: auto;\n  background-color: rgba(200, 200, 200, 0.7);\n}\n\n.elm-overlay-resume-words {\n  position: absolute;\n  top: calc(50% - 40px);\n  font-size: 80px;\n  line-height: 80px;\n  height: 80px;\n  width: 100%;\n}\n\n.elm-mini-controls {\n  position: fixed;\n  bottom: 0;\n  right: 6px;\n  border-radius: 4px;\n  background-color: rgb(61, 61, 61);\n  font-family: monospace;\n  pointer-events: auto;\n}\n\n.elm-mini-controls-button {\n  padding: 6px;\n  cursor: pointer;\n  text-align: center;\n  min-width: 24ch;\n}\n\n.elm-mini-controls-import-export {\n  padding: 4px 0;\n  font-size: 0.8em;\n  text-align: center;\n  background-color: rgb(50, 50, 50);\n}\n\n.elm-overlay-message {\n  position: absolute;\n  width: 600px;\n  height: 100%;\n  padding-left: calc(50% - 300px);\n  padding-right: calc(50% - 300px);\n  background-color: rgba(200, 200, 200, 0.7);\n  pointer-events: auto;\n}\n\n.elm-overlay-message-title {\n  font-size: 36px;\n  height: 80px;\n  background-color: rgb(50, 50, 50);\n  padding-left: 22px;\n  vertical-align: middle;\n  line-height: 80px;\n}\n\n.elm-overlay-message-details {\n  padding: 8px 20px;\n  overflow-y: auto;\n  max-height: calc(100% - 156px);\n  background-color: rgb(61, 61, 61);\n}\n\n.elm-overlay-message-details-type {\n  font-size: 1.5em;\n}\n\n.elm-overlay-message-details ul {\n  list-style-type: none;\n  padding-left: 20px;\n}\n\n.elm-overlay-message-details ul ul {\n  list-style-type: disc;\n  padding-left: 2em;\n}\n\n.elm-overlay-message-details li {\n  margin: 8px 0;\n}\n\n.elm-overlay-message-buttons {\n  height: 60px;\n  line-height: 60px;\n  text-align: right;\n  background-color: rgb(50, 50, 50);\n}\n\n.elm-overlay-message-buttons button {\n  margin-right: 20px;\n}\n\n'),
		_1: {ctor: '[]'}
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$button = F2(
	function (msg, label) {
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$span,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(msg),
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$style(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'cursor', _1: 'pointer'},
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(label),
				_1: {ctor: '[]'}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewImportExport = F3(
	function (props, importMsg, exportMsg) {
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			props,
			{
				ctor: '::',
				_0: A2(_elm_lang$virtual_dom$VirtualDom_Overlay$button, importMsg, 'Import'),
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' / '),
					_1: {
						ctor: '::',
						_0: A2(_elm_lang$virtual_dom$VirtualDom_Overlay$button, exportMsg, 'Export'),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewMiniControls = F2(
	function (config, numMsgs) {
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-mini-controls'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(config.open),
						_1: {
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-mini-controls-button'),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
							A2(
								_elm_lang$core$Basics_ops['++'],
								'Explore History (',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(numMsgs),
									')'))),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A3(
						_elm_lang$virtual_dom$VirtualDom_Overlay$viewImportExport,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-mini-controls-import-export'),
							_1: {ctor: '[]'}
						},
						config.importHistory,
						config.exportHistory),
					_1: {ctor: '[]'}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$addCommas = function (items) {
	var _p0 = items;
	if (_p0.ctor === '[]') {
		return '';
	} else {
		if (_p0._1.ctor === '[]') {
			return _p0._0;
		} else {
			if (_p0._1._1.ctor === '[]') {
				return A2(
					_elm_lang$core$Basics_ops['++'],
					_p0._0,
					A2(_elm_lang$core$Basics_ops['++'], ' and ', _p0._1._0));
			} else {
				return A2(
					_elm_lang$core$String$join,
					', ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p0._1,
						{
							ctor: '::',
							_0: A2(_elm_lang$core$Basics_ops['++'], ' and ', _p0._0),
							_1: {ctor: '[]'}
						}));
			}
		}
	}
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$problemToString = function (problem) {
	var _p1 = problem;
	switch (_p1.ctor) {
		case 'Function':
			return 'functions';
		case 'Decoder':
			return 'JSON decoders';
		case 'Task':
			return 'tasks';
		case 'Process':
			return 'processes';
		case 'Socket':
			return 'web sockets';
		case 'Request':
			return 'HTTP requests';
		case 'Program':
			return 'programs';
		default:
			return 'virtual DOM values';
	}
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$goodNews2 = '\nfunction can pattern match on that data and call whatever functions, JSON\ndecoders, etc. you need. This makes the code much more explicit and easy to\nfollow for other readers (or you in a few months!)\n';
var _elm_lang$virtual_dom$VirtualDom_Overlay$goodNews1 = '\nThe good news is that having values like this in your message type is not\nso great in the long run. You are better off using simpler data, like\n';
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode = function (name) {
	return A3(
		_elm_lang$virtual_dom$VirtualDom_Helpers$node,
		'code',
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(name),
			_1: {ctor: '[]'}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewMention = F2(
	function (tags, verbed) {
		var _p2 = A2(
			_elm_lang$core$List$map,
			_elm_lang$virtual_dom$VirtualDom_Overlay$viewCode,
			_elm_lang$core$List$reverse(tags));
		if (_p2.ctor === '[]') {
			return _elm_lang$virtual_dom$VirtualDom_Helpers$text('');
		} else {
			if (_p2._1.ctor === '[]') {
				return A3(
					_elm_lang$virtual_dom$VirtualDom_Helpers$node,
					'li',
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(verbed),
						_1: {
							ctor: '::',
							_0: _p2._0,
							_1: {
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('.'),
								_1: {ctor: '[]'}
							}
						}
					});
			} else {
				if (_p2._1._1.ctor === '[]') {
					return A3(
						_elm_lang$virtual_dom$VirtualDom_Helpers$node,
						'li',
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(verbed),
							_1: {
								ctor: '::',
								_0: _p2._1._0,
								_1: {
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' and '),
									_1: {
										ctor: '::',
										_0: _p2._0,
										_1: {
											ctor: '::',
											_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('.'),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						});
				} else {
					return A3(
						_elm_lang$virtual_dom$VirtualDom_Helpers$node,
						'li',
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(verbed),
							_1: A2(
								_elm_lang$core$Basics_ops['++'],
								A2(
									_elm_lang$core$List$intersperse,
									_elm_lang$virtual_dom$VirtualDom_Helpers$text(', '),
									_elm_lang$core$List$reverse(_p2._1)),
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(', and '),
									_1: {
										ctor: '::',
										_0: _p2._0,
										_1: {
											ctor: '::',
											_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('.'),
											_1: {ctor: '[]'}
										}
									}
								})
						});
				}
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewChange = function (change) {
	return A3(
		_elm_lang$virtual_dom$VirtualDom_Helpers$node,
		'li',
		{ctor: '[]'},
		function () {
			var _p3 = change;
			if (_p3.ctor === 'AliasChange') {
				return {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$span,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-message-details-type'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode(_p3._0),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				};
			} else {
				return {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$span,
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-message-details-type'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode(_p3._0),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A3(
							_elm_lang$virtual_dom$VirtualDom_Helpers$node,
							'ul',
							{ctor: '[]'},
							{
								ctor: '::',
								_0: A2(_elm_lang$virtual_dom$VirtualDom_Overlay$viewMention, _p3._1.removed, 'Removed '),
								_1: {
									ctor: '::',
									_0: A2(_elm_lang$virtual_dom$VirtualDom_Overlay$viewMention, _p3._1.changed, 'Changed '),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$virtual_dom$VirtualDom_Overlay$viewMention, _p3._1.added, 'Added '),
										_1: {ctor: '[]'}
									}
								}
							}),
						_1: {
							ctor: '::',
							_0: _p3._1.argsMatch ? _elm_lang$virtual_dom$VirtualDom_Helpers$text('') : _elm_lang$virtual_dom$VirtualDom_Helpers$text('This may be due to the fact that the type variable names changed.'),
							_1: {ctor: '[]'}
						}
					}
				};
			}
		}());
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewProblemType = function (_p4) {
	var _p5 = _p4;
	return A3(
		_elm_lang$virtual_dom$VirtualDom_Helpers$node,
		'li',
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode(_p5.name),
			_1: {
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
					A2(
						_elm_lang$core$Basics_ops['++'],
						' can contain ',
						A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$virtual_dom$VirtualDom_Overlay$addCommas(
								A2(_elm_lang$core$List$map, _elm_lang$virtual_dom$VirtualDom_Overlay$problemToString, _p5.problems)),
							'.'))),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewBadMetadata = function (_p6) {
	var _p7 = _p6;
	return {
		ctor: '::',
		_0: A3(
			_elm_lang$virtual_dom$VirtualDom_Helpers$node,
			'p',
			{ctor: '[]'},
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('The '),
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode(_p7.message),
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' type of your program cannot be reliably serialized for history files.'),
						_1: {ctor: '[]'}
					}
				}
			}),
		_1: {
			ctor: '::',
			_0: A3(
				_elm_lang$virtual_dom$VirtualDom_Helpers$node,
				'p',
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('Functions cannot be serialized, nor can values that contain functions. This is a problem in these places:'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A3(
					_elm_lang$virtual_dom$VirtualDom_Helpers$node,
					'ul',
					{ctor: '[]'},
					A2(_elm_lang$core$List$map, _elm_lang$virtual_dom$VirtualDom_Overlay$viewProblemType, _p7.problems)),
				_1: {
					ctor: '::',
					_0: A3(
						_elm_lang$virtual_dom$VirtualDom_Helpers$node,
						'p',
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_elm_lang$virtual_dom$VirtualDom_Overlay$goodNews1),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$a,
									{
										ctor: '::',
										_0: _elm_lang$virtual_dom$VirtualDom_Helpers$href('https://guide.elm-lang.org/types/union_types.html'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('union types'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(', in your messages. From there, your '),
									_1: {
										ctor: '::',
										_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode('update'),
										_1: {
											ctor: '::',
											_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_elm_lang$virtual_dom$VirtualDom_Overlay$goodNews2),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}),
					_1: {ctor: '[]'}
				}
			}
		}
	};
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$explanationRisky = '\nThis history seems old. It will work with this program, but some\nmessages have been added since the history was created:\n';
var _elm_lang$virtual_dom$VirtualDom_Overlay$explanationBad = '\nThe messages in this history do not match the messages handled by your\nprogram. I noticed changes in the following types:\n';
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewReport = F2(
	function (isBad, report) {
		var _p8 = report;
		switch (_p8.ctor) {
			case 'CorruptHistory':
				return {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('Looks like this history file is corrupt. I cannot understand it.'),
					_1: {ctor: '[]'}
				};
			case 'VersionChanged':
				return {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
						A2(
							_elm_lang$core$Basics_ops['++'],
							'This history was created with Elm ',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_p8._0,
								A2(
									_elm_lang$core$Basics_ops['++'],
									', but you are using Elm ',
									A2(_elm_lang$core$Basics_ops['++'], _p8._1, ' right now.'))))),
					_1: {ctor: '[]'}
				};
			case 'MessageChanged':
				return {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
						A2(_elm_lang$core$Basics_ops['++'], 'To import some other history, the overall message type must', ' be the same. The old history has ')),
					_1: {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode(_p8._0),
						_1: {
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' messages, but the new program works with '),
							_1: {
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewCode(_p8._1),
								_1: {
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' messages.'),
									_1: {ctor: '[]'}
								}
							}
						}
					}
				};
			default:
				return {
					ctor: '::',
					_0: A3(
						_elm_lang$virtual_dom$VirtualDom_Helpers$node,
						'p',
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(
								isBad ? _elm_lang$virtual_dom$VirtualDom_Overlay$explanationBad : _elm_lang$virtual_dom$VirtualDom_Overlay$explanationRisky),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A3(
							_elm_lang$virtual_dom$VirtualDom_Helpers$node,
							'ul',
							{ctor: '[]'},
							A2(_elm_lang$core$List$map, _elm_lang$virtual_dom$VirtualDom_Overlay$viewChange, _p8._0)),
						_1: {ctor: '[]'}
					}
				};
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewResume = function (config) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-resume'),
			_1: {
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(config.resume),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$virtual_dom$VirtualDom_Helpers$div,
				{
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-resume-words'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('Click to Resume'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$uploadDecoder = A3(
	_elm_lang$core$Json_Decode$map2,
	F2(
		function (v0, v1) {
			return {ctor: '_Tuple2', _0: v0, _1: v1};
		}),
	A2(_elm_lang$core$Json_Decode$field, 'metadata', _elm_lang$virtual_dom$VirtualDom_Metadata$decoder),
	A2(_elm_lang$core$Json_Decode$field, 'history', _elm_lang$core$Json_Decode$value));
var _elm_lang$virtual_dom$VirtualDom_Overlay$close = F2(
	function (msg, state) {
		var _p9 = state;
		switch (_p9.ctor) {
			case 'None':
				return _elm_lang$core$Maybe$Nothing;
			case 'BadMetadata':
				return _elm_lang$core$Maybe$Nothing;
			case 'BadImport':
				return _elm_lang$core$Maybe$Nothing;
			default:
				var _p10 = msg;
				if (_p10.ctor === 'Cancel') {
					return _elm_lang$core$Maybe$Nothing;
				} else {
					return _elm_lang$core$Maybe$Just(_p9._1);
				}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$isBlocking = function (state) {
	var _p11 = state;
	if (_p11.ctor === 'None') {
		return false;
	} else {
		return true;
	}
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$Config = F5(
	function (a, b, c, d, e) {
		return {resume: a, open: b, importHistory: c, exportHistory: d, wrap: e};
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$RiskyImport = F2(
	function (a, b) {
		return {ctor: 'RiskyImport', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$BadImport = function (a) {
	return {ctor: 'BadImport', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$corruptImport = _elm_lang$virtual_dom$VirtualDom_Overlay$BadImport(_elm_lang$virtual_dom$VirtualDom_Report$CorruptHistory);
var _elm_lang$virtual_dom$VirtualDom_Overlay$assessImport = F2(
	function (metadata, jsonString) {
		var _p12 = A2(_elm_lang$core$Json_Decode$decodeString, _elm_lang$virtual_dom$VirtualDom_Overlay$uploadDecoder, jsonString);
		if (_p12.ctor === 'Err') {
			return _elm_lang$core$Result$Err(_elm_lang$virtual_dom$VirtualDom_Overlay$corruptImport);
		} else {
			var _p14 = _p12._0._1;
			var report = A2(_elm_lang$virtual_dom$VirtualDom_Metadata$check, _p12._0._0, metadata);
			var _p13 = _elm_lang$virtual_dom$VirtualDom_Report$evaluate(report);
			switch (_p13.ctor) {
				case 'Impossible':
					return _elm_lang$core$Result$Err(
						_elm_lang$virtual_dom$VirtualDom_Overlay$BadImport(report));
				case 'Risky':
					return _elm_lang$core$Result$Err(
						A2(_elm_lang$virtual_dom$VirtualDom_Overlay$RiskyImport, report, _p14));
				default:
					return _elm_lang$core$Result$Ok(_p14);
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$BadMetadata = function (a) {
	return {ctor: 'BadMetadata', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$badMetadata = _elm_lang$virtual_dom$VirtualDom_Overlay$BadMetadata;
var _elm_lang$virtual_dom$VirtualDom_Overlay$None = {ctor: 'None'};
var _elm_lang$virtual_dom$VirtualDom_Overlay$none = _elm_lang$virtual_dom$VirtualDom_Overlay$None;
var _elm_lang$virtual_dom$VirtualDom_Overlay$Proceed = {ctor: 'Proceed'};
var _elm_lang$virtual_dom$VirtualDom_Overlay$Cancel = {ctor: 'Cancel'};
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewButtons = function (buttons) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-message-buttons'),
			_1: {ctor: '[]'}
		},
		function () {
			var _p15 = buttons;
			if (_p15.ctor === 'Accept') {
				return {
					ctor: '::',
					_0: A3(
						_elm_lang$virtual_dom$VirtualDom_Helpers$node,
						'button',
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Overlay$Proceed),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p15._0),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				};
			} else {
				return {
					ctor: '::',
					_0: A3(
						_elm_lang$virtual_dom$VirtualDom_Helpers$node,
						'button',
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Overlay$Cancel),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p15._0),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A3(
							_elm_lang$virtual_dom$VirtualDom_Helpers$node,
							'button',
							{
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Overlay$Proceed),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(_p15._1),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				};
			}
		}());
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$Message = {ctor: 'Message'};
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewMessage = F4(
	function (config, title, details, buttons) {
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$virtual_dom$VirtualDom_Overlay$Message,
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-message'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$virtual_dom$VirtualDom_Helpers$div,
							{
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-message-title'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(title),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$virtual_dom$VirtualDom_Helpers$div,
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay-message-details'),
									_1: {ctor: '[]'}
								},
								details),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$virtual_dom$VirtualDom_Helpers$map,
									config.wrap,
									_elm_lang$virtual_dom$VirtualDom_Overlay$viewButtons(buttons)),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {ctor: '[]'}
			}
		};
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$Pause = {ctor: 'Pause'};
var _elm_lang$virtual_dom$VirtualDom_Overlay$Normal = {ctor: 'Normal'};
var _elm_lang$virtual_dom$VirtualDom_Overlay$Choose = F2(
	function (a, b) {
		return {ctor: 'Choose', _0: a, _1: b};
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$Accept = function (a) {
	return {ctor: 'Accept', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Overlay$viewHelp = F5(
	function (config, isPaused, isOpen, numMsgs, state) {
		var _p16 = state;
		switch (_p16.ctor) {
			case 'None':
				var miniControls = isOpen ? {ctor: '[]'} : {
					ctor: '::',
					_0: A2(_elm_lang$virtual_dom$VirtualDom_Overlay$viewMiniControls, config, numMsgs),
					_1: {ctor: '[]'}
				};
				return {
					ctor: '_Tuple2',
					_0: isPaused ? _elm_lang$virtual_dom$VirtualDom_Overlay$Pause : _elm_lang$virtual_dom$VirtualDom_Overlay$Normal,
					_1: (isPaused && (!isOpen)) ? {
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Overlay$viewResume(config),
						_1: miniControls
					} : miniControls
				};
			case 'BadMetadata':
				return A4(
					_elm_lang$virtual_dom$VirtualDom_Overlay$viewMessage,
					config,
					'Cannot use Import or Export',
					_elm_lang$virtual_dom$VirtualDom_Overlay$viewBadMetadata(_p16._0),
					_elm_lang$virtual_dom$VirtualDom_Overlay$Accept('Ok'));
			case 'BadImport':
				return A4(
					_elm_lang$virtual_dom$VirtualDom_Overlay$viewMessage,
					config,
					'Cannot Import History',
					A2(_elm_lang$virtual_dom$VirtualDom_Overlay$viewReport, true, _p16._0),
					_elm_lang$virtual_dom$VirtualDom_Overlay$Accept('Ok'));
			default:
				return A4(
					_elm_lang$virtual_dom$VirtualDom_Overlay$viewMessage,
					config,
					'Warning',
					A2(_elm_lang$virtual_dom$VirtualDom_Overlay$viewReport, false, _p16._0),
					A2(_elm_lang$virtual_dom$VirtualDom_Overlay$Choose, 'Cancel', 'Import Anyway'));
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Overlay$view = F5(
	function (config, isPaused, isOpen, numMsgs, state) {
		var _p17 = A5(_elm_lang$virtual_dom$VirtualDom_Overlay$viewHelp, config, isPaused, isOpen, numMsgs, state);
		var block = _p17._0;
		var nodes = _p17._1;
		return {
			ctor: '_Tuple2',
			_0: block,
			_1: A2(
				_elm_lang$virtual_dom$VirtualDom_Helpers$div,
				{
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('elm-overlay'),
					_1: {ctor: '[]'}
				},
				{ctor: '::', _0: _elm_lang$virtual_dom$VirtualDom_Overlay$styles, _1: nodes})
		};
	});

var _elm_lang$virtual_dom$VirtualDom_Debug$styles = A3(
	_elm_lang$virtual_dom$VirtualDom_Helpers$node,
	'style',
	{ctor: '[]'},
	{
		ctor: '::',
		_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('\n\nhtml {\n    overflow: hidden;\n    height: 100%;\n}\n\nbody {\n    height: 100%;\n    overflow: auto;\n}\n\n#debugger {\n  width: 100%\n  height: 100%;\n  font-family: monospace;\n}\n\n#values {\n  display: block;\n  float: left;\n  height: 100%;\n  width: calc(100% - 30ch);\n  margin: 0;\n  overflow: auto;\n  cursor: default;\n}\n\n.debugger-sidebar {\n  display: block;\n  float: left;\n  width: 30ch;\n  height: 100%;\n  color: white;\n  background-color: rgb(61, 61, 61);\n}\n\n.debugger-sidebar-controls {\n  width: 100%;\n  text-align: center;\n  background-color: rgb(50, 50, 50);\n}\n\n.debugger-sidebar-controls-import-export {\n  width: 100%;\n  height: 24px;\n  line-height: 24px;\n  font-size: 12px;\n}\n\n.debugger-sidebar-controls-resume {\n  width: 100%;\n  height: 30px;\n  line-height: 30px;\n  cursor: pointer;\n}\n\n.debugger-sidebar-controls-resume:hover {\n  background-color: rgb(41, 41, 41);\n}\n\n.debugger-sidebar-messages {\n  width: 100%;\n  overflow-y: auto;\n  height: calc(100% - 24px);\n}\n\n.debugger-sidebar-messages-paused {\n  width: 100%;\n  overflow-y: auto;\n  height: calc(100% - 54px);\n}\n\n.messages-entry {\n  cursor: pointer;\n  width: 100%;\n}\n\n.messages-entry:hover {\n  background-color: rgb(41, 41, 41);\n}\n\n.messages-entry-selected, .messages-entry-selected:hover {\n  background-color: rgb(10, 10, 10);\n}\n\n.messages-entry-content {\n  width: calc(100% - 7ch);\n  padding-top: 4px;\n  padding-bottom: 4px;\n  padding-left: 1ch;\n  text-overflow: ellipsis;\n  white-space: nowrap;\n  overflow: hidden;\n  display: inline-block;\n}\n\n.messages-entry-index {\n  color: #666;\n  width: 5ch;\n  padding-top: 4px;\n  padding-bottom: 4px;\n  padding-right: 1ch;\n  text-align: right;\n  display: block;\n  float: right;\n}\n\n'),
		_1: {ctor: '[]'}
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$button = F2(
	function (msg, label) {
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$span,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(msg),
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Helpers$style(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'cursor', _1: 'pointer'},
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(label),
				_1: {ctor: '[]'}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$getLatestModel = function (state) {
	var _p0 = state;
	if (_p0.ctor === 'Running') {
		return _p0._0;
	} else {
		return _p0._2;
	}
};
var _elm_lang$virtual_dom$VirtualDom_Debug$withGoodMetadata = F2(
	function (model, func) {
		var _p1 = model.metadata;
		if (_p1.ctor === 'Ok') {
			return func(_p1._0);
		} else {
			return A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_elm_lang$core$Native_Utils.update(
					model,
					{
						overlay: _elm_lang$virtual_dom$VirtualDom_Overlay$badMetadata(_p1._0)
					}),
				{ctor: '[]'});
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$Model = F6(
	function (a, b, c, d, e, f) {
		return {history: a, state: b, expando: c, metadata: d, overlay: e, isDebuggerOpen: f};
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$Paused = F3(
	function (a, b, c) {
		return {ctor: 'Paused', _0: a, _1: b, _2: c};
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$Running = function (a) {
	return {ctor: 'Running', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Debug$loadNewHistory = F3(
	function (rawHistory, userUpdate, model) {
		var pureUserUpdate = F2(
			function (msg, userModel) {
				return _elm_lang$core$Tuple$first(
					A2(userUpdate, msg, userModel));
			});
		var initialUserModel = _elm_lang$virtual_dom$VirtualDom_History$initialModel(model.history);
		var decoder = A2(_elm_lang$virtual_dom$VirtualDom_History$decoder, initialUserModel, pureUserUpdate);
		var _p2 = A2(_elm_lang$core$Json_Decode$decodeValue, decoder, rawHistory);
		if (_p2.ctor === 'Err') {
			return A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_elm_lang$core$Native_Utils.update(
					model,
					{overlay: _elm_lang$virtual_dom$VirtualDom_Overlay$corruptImport}),
				{ctor: '[]'});
		} else {
			var _p3 = _p2._0._0;
			return A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_elm_lang$core$Native_Utils.update(
					model,
					{
						history: _p2._0._1,
						state: _elm_lang$virtual_dom$VirtualDom_Debug$Running(_p3),
						expando: _elm_lang$virtual_dom$VirtualDom_Expando$init(_p3),
						overlay: _elm_lang$virtual_dom$VirtualDom_Overlay$none
					}),
				{ctor: '[]'});
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$OverlayMsg = function (a) {
	return {ctor: 'OverlayMsg', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Debug$Upload = function (a) {
	return {ctor: 'Upload', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Debug$upload = A2(_elm_lang$core$Task$perform, _elm_lang$virtual_dom$VirtualDom_Debug$Upload, _elm_lang$virtual_dom$Native_Debug.upload);
var _elm_lang$virtual_dom$VirtualDom_Debug$Export = {ctor: 'Export'};
var _elm_lang$virtual_dom$VirtualDom_Debug$Import = {ctor: 'Import'};
var _elm_lang$virtual_dom$VirtualDom_Debug$Down = {ctor: 'Down'};
var _elm_lang$virtual_dom$VirtualDom_Debug$Up = {ctor: 'Up'};
var _elm_lang$virtual_dom$VirtualDom_Debug$Close = {ctor: 'Close'};
var _elm_lang$virtual_dom$VirtualDom_Debug$Open = {ctor: 'Open'};
var _elm_lang$virtual_dom$VirtualDom_Debug$Jump = function (a) {
	return {ctor: 'Jump', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Debug$Resume = {ctor: 'Resume'};
var _elm_lang$virtual_dom$VirtualDom_Debug$overlayConfig = {resume: _elm_lang$virtual_dom$VirtualDom_Debug$Resume, open: _elm_lang$virtual_dom$VirtualDom_Debug$Open, importHistory: _elm_lang$virtual_dom$VirtualDom_Debug$Import, exportHistory: _elm_lang$virtual_dom$VirtualDom_Debug$Export, wrap: _elm_lang$virtual_dom$VirtualDom_Debug$OverlayMsg};
var _elm_lang$virtual_dom$VirtualDom_Debug$viewIn = function (_p4) {
	var _p5 = _p4;
	var isPaused = function () {
		var _p6 = _p5.state;
		if (_p6.ctor === 'Running') {
			return false;
		} else {
			return true;
		}
	}();
	return A5(
		_elm_lang$virtual_dom$VirtualDom_Overlay$view,
		_elm_lang$virtual_dom$VirtualDom_Debug$overlayConfig,
		isPaused,
		_p5.isDebuggerOpen,
		_elm_lang$virtual_dom$VirtualDom_History$size(_p5.history),
		_p5.overlay);
};
var _elm_lang$virtual_dom$VirtualDom_Debug$resumeButton = A2(
	_elm_lang$virtual_dom$VirtualDom_Helpers$div,
	{
		ctor: '::',
		_0: _elm_lang$virtual_dom$VirtualDom_Helpers$onClick(_elm_lang$virtual_dom$VirtualDom_Debug$Resume),
		_1: {
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('debugger-sidebar-controls-resume'),
			_1: {ctor: '[]'}
		}
	},
	{
		ctor: '::',
		_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text('Resume'),
		_1: {ctor: '[]'}
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$viewResumeButton = function (maybeIndex) {
	var _p7 = maybeIndex;
	if (_p7.ctor === 'Nothing') {
		return _elm_lang$virtual_dom$VirtualDom_Helpers$text('');
	} else {
		return _elm_lang$virtual_dom$VirtualDom_Debug$resumeButton;
	}
};
var _elm_lang$virtual_dom$VirtualDom_Debug$playButton = function (maybeIndex) {
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('debugger-sidebar-controls'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Debug$viewResumeButton(maybeIndex),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$div,
					{
						ctor: '::',
						_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('debugger-sidebar-controls-import-export'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(_elm_lang$virtual_dom$VirtualDom_Debug$button, _elm_lang$virtual_dom$VirtualDom_Debug$Import, 'Import'),
						_1: {
							ctor: '::',
							_0: _elm_lang$virtual_dom$VirtualDom_Helpers$text(' / '),
							_1: {
								ctor: '::',
								_0: A2(_elm_lang$virtual_dom$VirtualDom_Debug$button, _elm_lang$virtual_dom$VirtualDom_Debug$Export, 'Export'),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Debug$viewSidebar = F2(
	function (state, history) {
		var maybeIndex = function () {
			var _p8 = state;
			if (_p8.ctor === 'Running') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				return _elm_lang$core$Maybe$Just(_p8._0);
			}
		}();
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$div,
			{
				ctor: '::',
				_0: _elm_lang$virtual_dom$VirtualDom_Helpers$class('debugger-sidebar'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$virtual_dom$VirtualDom_Helpers$map,
					_elm_lang$virtual_dom$VirtualDom_Debug$Jump,
					A2(_elm_lang$virtual_dom$VirtualDom_History$view, maybeIndex, history)),
				_1: {
					ctor: '::',
					_0: _elm_lang$virtual_dom$VirtualDom_Debug$playButton(maybeIndex),
					_1: {ctor: '[]'}
				}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$ExpandoMsg = function (a) {
	return {ctor: 'ExpandoMsg', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Debug$viewOut = function (_p9) {
	var _p10 = _p9;
	return A2(
		_elm_lang$virtual_dom$VirtualDom_Helpers$div,
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Helpers$id('debugger'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _elm_lang$virtual_dom$VirtualDom_Debug$styles,
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$virtual_dom$VirtualDom_Debug$viewSidebar, _p10.state, _p10.history),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$virtual_dom$VirtualDom_Helpers$map,
						_elm_lang$virtual_dom$VirtualDom_Debug$ExpandoMsg,
						A2(
							_elm_lang$virtual_dom$VirtualDom_Helpers$div,
							{
								ctor: '::',
								_0: _elm_lang$virtual_dom$VirtualDom_Helpers$id('values'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(_elm_lang$virtual_dom$VirtualDom_Expando$view, _elm_lang$core$Maybe$Nothing, _p10.expando),
								_1: {ctor: '[]'}
							})),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _elm_lang$virtual_dom$VirtualDom_Debug$UserMsg = function (a) {
	return {ctor: 'UserMsg', _0: a};
};
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapInit = F2(
	function (metadata, _p11) {
		var _p12 = _p11;
		var _p13 = _p12._0;
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			{
				history: _elm_lang$virtual_dom$VirtualDom_History$empty(_p13),
				state: _elm_lang$virtual_dom$VirtualDom_Debug$Running(_p13),
				expando: _elm_lang$virtual_dom$VirtualDom_Expando$init(_p13),
				metadata: _elm_lang$virtual_dom$VirtualDom_Metadata$decode(metadata),
				overlay: _elm_lang$virtual_dom$VirtualDom_Overlay$none,
				isDebuggerOpen: false
			},
			{
				ctor: '::',
				_0: A2(_elm_lang$core$Platform_Cmd$map, _elm_lang$virtual_dom$VirtualDom_Debug$UserMsg, _p12._1),
				_1: {ctor: '[]'}
			});
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapSubs = F2(
	function (userSubscriptions, _p14) {
		var _p15 = _p14;
		return A2(
			_elm_lang$core$Platform_Sub$map,
			_elm_lang$virtual_dom$VirtualDom_Debug$UserMsg,
			userSubscriptions(
				_elm_lang$virtual_dom$VirtualDom_Debug$getLatestModel(_p15.state)));
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapView = F2(
	function (userView, _p16) {
		var _p17 = _p16;
		var currentModel = function () {
			var _p18 = _p17.state;
			if (_p18.ctor === 'Running') {
				return _p18._0;
			} else {
				return _p18._1;
			}
		}();
		return A2(
			_elm_lang$virtual_dom$VirtualDom_Helpers$map,
			_elm_lang$virtual_dom$VirtualDom_Debug$UserMsg,
			userView(currentModel));
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$NoOp = {ctor: 'NoOp'};
var _elm_lang$virtual_dom$VirtualDom_Debug$download = F2(
	function (metadata, history) {
		var json = _elm_lang$core$Json_Encode$object(
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'metadata',
					_1: _elm_lang$virtual_dom$VirtualDom_Metadata$encode(metadata)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'history',
						_1: _elm_lang$virtual_dom$VirtualDom_History$encode(history)
					},
					_1: {ctor: '[]'}
				}
			});
		var historyLength = _elm_lang$virtual_dom$VirtualDom_History$size(history);
		return A2(
			_elm_lang$core$Task$perform,
			function (_p19) {
				return _elm_lang$virtual_dom$VirtualDom_Debug$NoOp;
			},
			A2(_elm_lang$virtual_dom$Native_Debug.download, historyLength, json));
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$runIf = F2(
	function (bool, task) {
		return bool ? A2(
			_elm_lang$core$Task$perform,
			_elm_lang$core$Basics$always(_elm_lang$virtual_dom$VirtualDom_Debug$NoOp),
			task) : _elm_lang$core$Platform_Cmd$none;
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$updateUserMsg = F4(
	function (userUpdate, scrollTask, userMsg, _p20) {
		var _p21 = _p20;
		var _p25 = _p21.state;
		var _p24 = _p21;
		var userModel = _elm_lang$virtual_dom$VirtualDom_Debug$getLatestModel(_p25);
		var newHistory = A3(_elm_lang$virtual_dom$VirtualDom_History$add, userMsg, userModel, _p21.history);
		var _p22 = A2(userUpdate, userMsg, userModel);
		var newUserModel = _p22._0;
		var userCmds = _p22._1;
		var commands = A2(_elm_lang$core$Platform_Cmd$map, _elm_lang$virtual_dom$VirtualDom_Debug$UserMsg, userCmds);
		var _p23 = _p25;
		if (_p23.ctor === 'Running') {
			return A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_elm_lang$core$Native_Utils.update(
					_p24,
					{
						history: newHistory,
						state: _elm_lang$virtual_dom$VirtualDom_Debug$Running(newUserModel),
						expando: A2(_elm_lang$virtual_dom$VirtualDom_Expando$merge, newUserModel, _p21.expando)
					}),
				{
					ctor: '::',
					_0: commands,
					_1: {
						ctor: '::',
						_0: A2(_elm_lang$virtual_dom$VirtualDom_Debug$runIf, _p24.isDebuggerOpen, scrollTask),
						_1: {ctor: '[]'}
					}
				});
		} else {
			return A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_elm_lang$core$Native_Utils.update(
					_p24,
					{
						history: newHistory,
						state: A3(_elm_lang$virtual_dom$VirtualDom_Debug$Paused, _p23._0, _p23._1, newUserModel)
					}),
				{
					ctor: '::',
					_0: commands,
					_1: {ctor: '[]'}
				});
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapUpdate = F4(
	function (userUpdate, scrollTask, msg, model) {
		wrapUpdate:
		while (true) {
			var _p26 = msg;
			switch (_p26.ctor) {
				case 'NoOp':
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				case 'UserMsg':
					return A4(_elm_lang$virtual_dom$VirtualDom_Debug$updateUserMsg, userUpdate, scrollTask, _p26._0, model);
				case 'ExpandoMsg':
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{
								expando: A2(_elm_lang$virtual_dom$VirtualDom_Expando$update, _p26._0, model.expando)
							}),
						{ctor: '[]'});
				case 'Resume':
					var _p27 = model.state;
					if (_p27.ctor === 'Running') {
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							model,
							{ctor: '[]'});
					} else {
						var _p28 = _p27._2;
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{
									state: _elm_lang$virtual_dom$VirtualDom_Debug$Running(_p28),
									expando: A2(_elm_lang$virtual_dom$VirtualDom_Expando$merge, _p28, model.expando)
								}),
							{
								ctor: '::',
								_0: A2(_elm_lang$virtual_dom$VirtualDom_Debug$runIf, model.isDebuggerOpen, scrollTask),
								_1: {ctor: '[]'}
							});
					}
				case 'Jump':
					var _p30 = _p26._0;
					var _p29 = A3(_elm_lang$virtual_dom$VirtualDom_History$get, userUpdate, _p30, model.history);
					var indexModel = _p29._0;
					var indexMsg = _p29._1;
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{
								state: A3(
									_elm_lang$virtual_dom$VirtualDom_Debug$Paused,
									_p30,
									indexModel,
									_elm_lang$virtual_dom$VirtualDom_Debug$getLatestModel(model.state)),
								expando: A2(_elm_lang$virtual_dom$VirtualDom_Expando$merge, indexModel, model.expando)
							}),
						{ctor: '[]'});
				case 'Open':
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{isDebuggerOpen: true}),
						{ctor: '[]'});
				case 'Close':
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{isDebuggerOpen: false}),
						{ctor: '[]'});
				case 'Up':
					var index = function () {
						var _p31 = model.state;
						if (_p31.ctor === 'Paused') {
							return _p31._0;
						} else {
							return _elm_lang$virtual_dom$VirtualDom_History$size(model.history);
						}
					}();
					if (_elm_lang$core$Native_Utils.cmp(index, 0) > 0) {
						var _v17 = userUpdate,
							_v18 = scrollTask,
							_v19 = _elm_lang$virtual_dom$VirtualDom_Debug$Jump(index - 1),
							_v20 = model;
						userUpdate = _v17;
						scrollTask = _v18;
						msg = _v19;
						model = _v20;
						continue wrapUpdate;
					} else {
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							model,
							{ctor: '[]'});
					}
				case 'Down':
					var _p32 = model.state;
					if (_p32.ctor === 'Running') {
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							model,
							{ctor: '[]'});
					} else {
						var _p33 = _p32._0;
						if (_elm_lang$core$Native_Utils.eq(
							_p33,
							_elm_lang$virtual_dom$VirtualDom_History$size(model.history) - 1)) {
							var _v22 = userUpdate,
								_v23 = scrollTask,
								_v24 = _elm_lang$virtual_dom$VirtualDom_Debug$Resume,
								_v25 = model;
							userUpdate = _v22;
							scrollTask = _v23;
							msg = _v24;
							model = _v25;
							continue wrapUpdate;
						} else {
							var _v26 = userUpdate,
								_v27 = scrollTask,
								_v28 = _elm_lang$virtual_dom$VirtualDom_Debug$Jump(_p33 + 1),
								_v29 = model;
							userUpdate = _v26;
							scrollTask = _v27;
							msg = _v28;
							model = _v29;
							continue wrapUpdate;
						}
					}
				case 'Import':
					return A2(
						_elm_lang$virtual_dom$VirtualDom_Debug$withGoodMetadata,
						model,
						function (_p34) {
							return A2(
								_elm_lang$core$Platform_Cmd_ops['!'],
								model,
								{
									ctor: '::',
									_0: _elm_lang$virtual_dom$VirtualDom_Debug$upload,
									_1: {ctor: '[]'}
								});
						});
				case 'Export':
					return A2(
						_elm_lang$virtual_dom$VirtualDom_Debug$withGoodMetadata,
						model,
						function (metadata) {
							return A2(
								_elm_lang$core$Platform_Cmd_ops['!'],
								model,
								{
									ctor: '::',
									_0: A2(_elm_lang$virtual_dom$VirtualDom_Debug$download, metadata, model.history),
									_1: {ctor: '[]'}
								});
						});
				case 'Upload':
					return A2(
						_elm_lang$virtual_dom$VirtualDom_Debug$withGoodMetadata,
						model,
						function (metadata) {
							var _p35 = A2(_elm_lang$virtual_dom$VirtualDom_Overlay$assessImport, metadata, _p26._0);
							if (_p35.ctor === 'Err') {
								return A2(
									_elm_lang$core$Platform_Cmd_ops['!'],
									_elm_lang$core$Native_Utils.update(
										model,
										{overlay: _p35._0}),
									{ctor: '[]'});
							} else {
								return A3(_elm_lang$virtual_dom$VirtualDom_Debug$loadNewHistory, _p35._0, userUpdate, model);
							}
						});
				default:
					var _p36 = A2(_elm_lang$virtual_dom$VirtualDom_Overlay$close, _p26._0, model.overlay);
					if (_p36.ctor === 'Nothing') {
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{overlay: _elm_lang$virtual_dom$VirtualDom_Overlay$none}),
							{ctor: '[]'});
					} else {
						return A3(_elm_lang$virtual_dom$VirtualDom_Debug$loadNewHistory, _p36._0, userUpdate, model);
					}
			}
		}
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$wrap = F2(
	function (metadata, _p37) {
		var _p38 = _p37;
		return {
			init: A2(_elm_lang$virtual_dom$VirtualDom_Debug$wrapInit, metadata, _p38.init),
			view: _elm_lang$virtual_dom$VirtualDom_Debug$wrapView(_p38.view),
			update: _elm_lang$virtual_dom$VirtualDom_Debug$wrapUpdate(_p38.update),
			viewIn: _elm_lang$virtual_dom$VirtualDom_Debug$viewIn,
			viewOut: _elm_lang$virtual_dom$VirtualDom_Debug$viewOut,
			subscriptions: _elm_lang$virtual_dom$VirtualDom_Debug$wrapSubs(_p38.subscriptions)
		};
	});
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags = F2(
	function (metadata, _p39) {
		var _p40 = _p39;
		return {
			init: function (flags) {
				return A2(
					_elm_lang$virtual_dom$VirtualDom_Debug$wrapInit,
					metadata,
					_p40.init(flags));
			},
			view: _elm_lang$virtual_dom$VirtualDom_Debug$wrapView(_p40.view),
			update: _elm_lang$virtual_dom$VirtualDom_Debug$wrapUpdate(_p40.update),
			viewIn: _elm_lang$virtual_dom$VirtualDom_Debug$viewIn,
			viewOut: _elm_lang$virtual_dom$VirtualDom_Debug$viewOut,
			subscriptions: _elm_lang$virtual_dom$VirtualDom_Debug$wrapSubs(_p40.subscriptions)
		};
	});

var _elm_lang$virtual_dom$VirtualDom$programWithFlags = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.programWithFlags, _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags, impl);
};
var _elm_lang$virtual_dom$VirtualDom$program = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, impl);
};
var _elm_lang$virtual_dom$VirtualDom$keyedNode = _elm_lang$virtual_dom$Native_VirtualDom.keyedNode;
var _elm_lang$virtual_dom$VirtualDom$lazy3 = _elm_lang$virtual_dom$Native_VirtualDom.lazy3;
var _elm_lang$virtual_dom$VirtualDom$lazy2 = _elm_lang$virtual_dom$Native_VirtualDom.lazy2;
var _elm_lang$virtual_dom$VirtualDom$lazy = _elm_lang$virtual_dom$Native_VirtualDom.lazy;
var _elm_lang$virtual_dom$VirtualDom$defaultOptions = {stopPropagation: false, preventDefault: false};
var _elm_lang$virtual_dom$VirtualDom$onWithOptions = _elm_lang$virtual_dom$Native_VirtualDom.on;
var _elm_lang$virtual_dom$VirtualDom$on = F2(
	function (eventName, decoder) {
		return A3(_elm_lang$virtual_dom$VirtualDom$onWithOptions, eventName, _elm_lang$virtual_dom$VirtualDom$defaultOptions, decoder);
	});
var _elm_lang$virtual_dom$VirtualDom$style = _elm_lang$virtual_dom$Native_VirtualDom.style;
var _elm_lang$virtual_dom$VirtualDom$mapProperty = _elm_lang$virtual_dom$Native_VirtualDom.mapProperty;
var _elm_lang$virtual_dom$VirtualDom$attributeNS = _elm_lang$virtual_dom$Native_VirtualDom.attributeNS;
var _elm_lang$virtual_dom$VirtualDom$attribute = _elm_lang$virtual_dom$Native_VirtualDom.attribute;
var _elm_lang$virtual_dom$VirtualDom$property = _elm_lang$virtual_dom$Native_VirtualDom.property;
var _elm_lang$virtual_dom$VirtualDom$map = _elm_lang$virtual_dom$Native_VirtualDom.map;
var _elm_lang$virtual_dom$VirtualDom$text = _elm_lang$virtual_dom$Native_VirtualDom.text;
var _elm_lang$virtual_dom$VirtualDom$node = _elm_lang$virtual_dom$Native_VirtualDom.node;
var _elm_lang$virtual_dom$VirtualDom$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});
var _elm_lang$virtual_dom$VirtualDom$Node = {ctor: 'Node'};
var _elm_lang$virtual_dom$VirtualDom$Property = {ctor: 'Property'};

var _elm_lang$html$Html$programWithFlags = _elm_lang$virtual_dom$VirtualDom$programWithFlags;
var _elm_lang$html$Html$program = _elm_lang$virtual_dom$VirtualDom$program;
var _elm_lang$html$Html$beginnerProgram = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$html$Html$program(
		{
			init: A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_p1.model,
				{ctor: '[]'}),
			update: F2(
				function (msg, model) {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						A2(_p1.update, msg, model),
						{ctor: '[]'});
				}),
			view: _p1.view,
			subscriptions: function (_p2) {
				return _elm_lang$core$Platform_Sub$none;
			}
		});
};
var _elm_lang$html$Html$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$html$Html$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$html$Html$node = _elm_lang$virtual_dom$VirtualDom$node;
var _elm_lang$html$Html$body = _elm_lang$html$Html$node('body');
var _elm_lang$html$Html$section = _elm_lang$html$Html$node('section');
var _elm_lang$html$Html$nav = _elm_lang$html$Html$node('nav');
var _elm_lang$html$Html$article = _elm_lang$html$Html$node('article');
var _elm_lang$html$Html$aside = _elm_lang$html$Html$node('aside');
var _elm_lang$html$Html$h1 = _elm_lang$html$Html$node('h1');
var _elm_lang$html$Html$h2 = _elm_lang$html$Html$node('h2');
var _elm_lang$html$Html$h3 = _elm_lang$html$Html$node('h3');
var _elm_lang$html$Html$h4 = _elm_lang$html$Html$node('h4');
var _elm_lang$html$Html$h5 = _elm_lang$html$Html$node('h5');
var _elm_lang$html$Html$h6 = _elm_lang$html$Html$node('h6');
var _elm_lang$html$Html$header = _elm_lang$html$Html$node('header');
var _elm_lang$html$Html$footer = _elm_lang$html$Html$node('footer');
var _elm_lang$html$Html$address = _elm_lang$html$Html$node('address');
var _elm_lang$html$Html$main_ = _elm_lang$html$Html$node('main');
var _elm_lang$html$Html$p = _elm_lang$html$Html$node('p');
var _elm_lang$html$Html$hr = _elm_lang$html$Html$node('hr');
var _elm_lang$html$Html$pre = _elm_lang$html$Html$node('pre');
var _elm_lang$html$Html$blockquote = _elm_lang$html$Html$node('blockquote');
var _elm_lang$html$Html$ol = _elm_lang$html$Html$node('ol');
var _elm_lang$html$Html$ul = _elm_lang$html$Html$node('ul');
var _elm_lang$html$Html$li = _elm_lang$html$Html$node('li');
var _elm_lang$html$Html$dl = _elm_lang$html$Html$node('dl');
var _elm_lang$html$Html$dt = _elm_lang$html$Html$node('dt');
var _elm_lang$html$Html$dd = _elm_lang$html$Html$node('dd');
var _elm_lang$html$Html$figure = _elm_lang$html$Html$node('figure');
var _elm_lang$html$Html$figcaption = _elm_lang$html$Html$node('figcaption');
var _elm_lang$html$Html$div = _elm_lang$html$Html$node('div');
var _elm_lang$html$Html$a = _elm_lang$html$Html$node('a');
var _elm_lang$html$Html$em = _elm_lang$html$Html$node('em');
var _elm_lang$html$Html$strong = _elm_lang$html$Html$node('strong');
var _elm_lang$html$Html$small = _elm_lang$html$Html$node('small');
var _elm_lang$html$Html$s = _elm_lang$html$Html$node('s');
var _elm_lang$html$Html$cite = _elm_lang$html$Html$node('cite');
var _elm_lang$html$Html$q = _elm_lang$html$Html$node('q');
var _elm_lang$html$Html$dfn = _elm_lang$html$Html$node('dfn');
var _elm_lang$html$Html$abbr = _elm_lang$html$Html$node('abbr');
var _elm_lang$html$Html$time = _elm_lang$html$Html$node('time');
var _elm_lang$html$Html$code = _elm_lang$html$Html$node('code');
var _elm_lang$html$Html$var = _elm_lang$html$Html$node('var');
var _elm_lang$html$Html$samp = _elm_lang$html$Html$node('samp');
var _elm_lang$html$Html$kbd = _elm_lang$html$Html$node('kbd');
var _elm_lang$html$Html$sub = _elm_lang$html$Html$node('sub');
var _elm_lang$html$Html$sup = _elm_lang$html$Html$node('sup');
var _elm_lang$html$Html$i = _elm_lang$html$Html$node('i');
var _elm_lang$html$Html$b = _elm_lang$html$Html$node('b');
var _elm_lang$html$Html$u = _elm_lang$html$Html$node('u');
var _elm_lang$html$Html$mark = _elm_lang$html$Html$node('mark');
var _elm_lang$html$Html$ruby = _elm_lang$html$Html$node('ruby');
var _elm_lang$html$Html$rt = _elm_lang$html$Html$node('rt');
var _elm_lang$html$Html$rp = _elm_lang$html$Html$node('rp');
var _elm_lang$html$Html$bdi = _elm_lang$html$Html$node('bdi');
var _elm_lang$html$Html$bdo = _elm_lang$html$Html$node('bdo');
var _elm_lang$html$Html$span = _elm_lang$html$Html$node('span');
var _elm_lang$html$Html$br = _elm_lang$html$Html$node('br');
var _elm_lang$html$Html$wbr = _elm_lang$html$Html$node('wbr');
var _elm_lang$html$Html$ins = _elm_lang$html$Html$node('ins');
var _elm_lang$html$Html$del = _elm_lang$html$Html$node('del');
var _elm_lang$html$Html$img = _elm_lang$html$Html$node('img');
var _elm_lang$html$Html$iframe = _elm_lang$html$Html$node('iframe');
var _elm_lang$html$Html$embed = _elm_lang$html$Html$node('embed');
var _elm_lang$html$Html$object = _elm_lang$html$Html$node('object');
var _elm_lang$html$Html$param = _elm_lang$html$Html$node('param');
var _elm_lang$html$Html$video = _elm_lang$html$Html$node('video');
var _elm_lang$html$Html$audio = _elm_lang$html$Html$node('audio');
var _elm_lang$html$Html$source = _elm_lang$html$Html$node('source');
var _elm_lang$html$Html$track = _elm_lang$html$Html$node('track');
var _elm_lang$html$Html$canvas = _elm_lang$html$Html$node('canvas');
var _elm_lang$html$Html$math = _elm_lang$html$Html$node('math');
var _elm_lang$html$Html$table = _elm_lang$html$Html$node('table');
var _elm_lang$html$Html$caption = _elm_lang$html$Html$node('caption');
var _elm_lang$html$Html$colgroup = _elm_lang$html$Html$node('colgroup');
var _elm_lang$html$Html$col = _elm_lang$html$Html$node('col');
var _elm_lang$html$Html$tbody = _elm_lang$html$Html$node('tbody');
var _elm_lang$html$Html$thead = _elm_lang$html$Html$node('thead');
var _elm_lang$html$Html$tfoot = _elm_lang$html$Html$node('tfoot');
var _elm_lang$html$Html$tr = _elm_lang$html$Html$node('tr');
var _elm_lang$html$Html$td = _elm_lang$html$Html$node('td');
var _elm_lang$html$Html$th = _elm_lang$html$Html$node('th');
var _elm_lang$html$Html$form = _elm_lang$html$Html$node('form');
var _elm_lang$html$Html$fieldset = _elm_lang$html$Html$node('fieldset');
var _elm_lang$html$Html$legend = _elm_lang$html$Html$node('legend');
var _elm_lang$html$Html$label = _elm_lang$html$Html$node('label');
var _elm_lang$html$Html$input = _elm_lang$html$Html$node('input');
var _elm_lang$html$Html$button = _elm_lang$html$Html$node('button');
var _elm_lang$html$Html$select = _elm_lang$html$Html$node('select');
var _elm_lang$html$Html$datalist = _elm_lang$html$Html$node('datalist');
var _elm_lang$html$Html$optgroup = _elm_lang$html$Html$node('optgroup');
var _elm_lang$html$Html$option = _elm_lang$html$Html$node('option');
var _elm_lang$html$Html$textarea = _elm_lang$html$Html$node('textarea');
var _elm_lang$html$Html$keygen = _elm_lang$html$Html$node('keygen');
var _elm_lang$html$Html$output = _elm_lang$html$Html$node('output');
var _elm_lang$html$Html$progress = _elm_lang$html$Html$node('progress');
var _elm_lang$html$Html$meter = _elm_lang$html$Html$node('meter');
var _elm_lang$html$Html$details = _elm_lang$html$Html$node('details');
var _elm_lang$html$Html$summary = _elm_lang$html$Html$node('summary');
var _elm_lang$html$Html$menuitem = _elm_lang$html$Html$node('menuitem');
var _elm_lang$html$Html$menu = _elm_lang$html$Html$node('menu');

var _elm_lang$html$Html_Attributes$map = _elm_lang$virtual_dom$VirtualDom$mapProperty;
var _elm_lang$html$Html_Attributes$attribute = _elm_lang$virtual_dom$VirtualDom$attribute;
var _elm_lang$html$Html_Attributes$contextmenu = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'contextmenu', value);
};
var _elm_lang$html$Html_Attributes$draggable = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'draggable', value);
};
var _elm_lang$html$Html_Attributes$itemprop = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'itemprop', value);
};
var _elm_lang$html$Html_Attributes$tabindex = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'tabIndex',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$charset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'charset', value);
};
var _elm_lang$html$Html_Attributes$height = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'height',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$width = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'width',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$formaction = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'formAction', value);
};
var _elm_lang$html$Html_Attributes$list = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'list', value);
};
var _elm_lang$html$Html_Attributes$minlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'minLength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$maxlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'maxlength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$size = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'size',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$form = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'form', value);
};
var _elm_lang$html$Html_Attributes$cols = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'cols',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rows = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rows',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$challenge = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'challenge', value);
};
var _elm_lang$html$Html_Attributes$media = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'media', value);
};
var _elm_lang$html$Html_Attributes$rel = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'rel', value);
};
var _elm_lang$html$Html_Attributes$datetime = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'datetime', value);
};
var _elm_lang$html$Html_Attributes$pubdate = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'pubdate', value);
};
var _elm_lang$html$Html_Attributes$colspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'colspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rowspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rowspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$manifest = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'manifest', value);
};
var _elm_lang$html$Html_Attributes$property = _elm_lang$virtual_dom$VirtualDom$property;
var _elm_lang$html$Html_Attributes$stringProperty = F2(
	function (name, string) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$string(string));
	});
var _elm_lang$html$Html_Attributes$class = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'className', name);
};
var _elm_lang$html$Html_Attributes$id = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'id', name);
};
var _elm_lang$html$Html_Attributes$title = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'title', name);
};
var _elm_lang$html$Html_Attributes$accesskey = function ($char) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'accessKey',
		_elm_lang$core$String$fromChar($char));
};
var _elm_lang$html$Html_Attributes$dir = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dir', value);
};
var _elm_lang$html$Html_Attributes$dropzone = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dropzone', value);
};
var _elm_lang$html$Html_Attributes$lang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'lang', value);
};
var _elm_lang$html$Html_Attributes$content = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'content', value);
};
var _elm_lang$html$Html_Attributes$httpEquiv = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'httpEquiv', value);
};
var _elm_lang$html$Html_Attributes$language = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'language', value);
};
var _elm_lang$html$Html_Attributes$src = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'src', value);
};
var _elm_lang$html$Html_Attributes$alt = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'alt', value);
};
var _elm_lang$html$Html_Attributes$preload = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'preload', value);
};
var _elm_lang$html$Html_Attributes$poster = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'poster', value);
};
var _elm_lang$html$Html_Attributes$kind = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'kind', value);
};
var _elm_lang$html$Html_Attributes$srclang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srclang', value);
};
var _elm_lang$html$Html_Attributes$sandbox = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'sandbox', value);
};
var _elm_lang$html$Html_Attributes$srcdoc = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srcdoc', value);
};
var _elm_lang$html$Html_Attributes$type_ = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'type', value);
};
var _elm_lang$html$Html_Attributes$value = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'value', value);
};
var _elm_lang$html$Html_Attributes$defaultValue = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'defaultValue', value);
};
var _elm_lang$html$Html_Attributes$placeholder = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'placeholder', value);
};
var _elm_lang$html$Html_Attributes$accept = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'accept', value);
};
var _elm_lang$html$Html_Attributes$acceptCharset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'acceptCharset', value);
};
var _elm_lang$html$Html_Attributes$action = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'action', value);
};
var _elm_lang$html$Html_Attributes$autocomplete = function (bool) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'autocomplete',
		bool ? 'on' : 'off');
};
var _elm_lang$html$Html_Attributes$enctype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'enctype', value);
};
var _elm_lang$html$Html_Attributes$method = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'method', value);
};
var _elm_lang$html$Html_Attributes$name = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'name', value);
};
var _elm_lang$html$Html_Attributes$pattern = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'pattern', value);
};
var _elm_lang$html$Html_Attributes$for = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'htmlFor', value);
};
var _elm_lang$html$Html_Attributes$max = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'max', value);
};
var _elm_lang$html$Html_Attributes$min = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'min', value);
};
var _elm_lang$html$Html_Attributes$step = function (n) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'step', n);
};
var _elm_lang$html$Html_Attributes$wrap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'wrap', value);
};
var _elm_lang$html$Html_Attributes$usemap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'useMap', value);
};
var _elm_lang$html$Html_Attributes$shape = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'shape', value);
};
var _elm_lang$html$Html_Attributes$coords = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'coords', value);
};
var _elm_lang$html$Html_Attributes$keytype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'keytype', value);
};
var _elm_lang$html$Html_Attributes$align = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'align', value);
};
var _elm_lang$html$Html_Attributes$cite = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'cite', value);
};
var _elm_lang$html$Html_Attributes$href = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'href', value);
};
var _elm_lang$html$Html_Attributes$target = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'target', value);
};
var _elm_lang$html$Html_Attributes$downloadAs = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'download', value);
};
var _elm_lang$html$Html_Attributes$hreflang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'hreflang', value);
};
var _elm_lang$html$Html_Attributes$ping = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'ping', value);
};
var _elm_lang$html$Html_Attributes$start = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'start',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$headers = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'headers', value);
};
var _elm_lang$html$Html_Attributes$scope = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'scope', value);
};
var _elm_lang$html$Html_Attributes$boolProperty = F2(
	function (name, bool) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$bool(bool));
	});
var _elm_lang$html$Html_Attributes$hidden = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'hidden', bool);
};
var _elm_lang$html$Html_Attributes$contenteditable = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'contentEditable', bool);
};
var _elm_lang$html$Html_Attributes$spellcheck = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'spellcheck', bool);
};
var _elm_lang$html$Html_Attributes$async = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'async', bool);
};
var _elm_lang$html$Html_Attributes$defer = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'defer', bool);
};
var _elm_lang$html$Html_Attributes$scoped = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'scoped', bool);
};
var _elm_lang$html$Html_Attributes$autoplay = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autoplay', bool);
};
var _elm_lang$html$Html_Attributes$controls = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'controls', bool);
};
var _elm_lang$html$Html_Attributes$loop = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'loop', bool);
};
var _elm_lang$html$Html_Attributes$default = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'default', bool);
};
var _elm_lang$html$Html_Attributes$seamless = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'seamless', bool);
};
var _elm_lang$html$Html_Attributes$checked = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'checked', bool);
};
var _elm_lang$html$Html_Attributes$selected = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'selected', bool);
};
var _elm_lang$html$Html_Attributes$autofocus = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autofocus', bool);
};
var _elm_lang$html$Html_Attributes$disabled = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'disabled', bool);
};
var _elm_lang$html$Html_Attributes$multiple = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'multiple', bool);
};
var _elm_lang$html$Html_Attributes$novalidate = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'noValidate', bool);
};
var _elm_lang$html$Html_Attributes$readonly = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'readOnly', bool);
};
var _elm_lang$html$Html_Attributes$required = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'required', bool);
};
var _elm_lang$html$Html_Attributes$ismap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'isMap', value);
};
var _elm_lang$html$Html_Attributes$download = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'download', bool);
};
var _elm_lang$html$Html_Attributes$reversed = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'reversed', bool);
};
var _elm_lang$html$Html_Attributes$classList = function (list) {
	return _elm_lang$html$Html_Attributes$class(
		A2(
			_elm_lang$core$String$join,
			' ',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Tuple$first,
				A2(_elm_lang$core$List$filter, _elm_lang$core$Tuple$second, list))));
};
var _elm_lang$html$Html_Attributes$style = _elm_lang$virtual_dom$VirtualDom$style;

var _elm_lang$html$Html_Events$keyCode = A2(_elm_lang$core$Json_Decode$field, 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$html$Html_Events$targetChecked = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'checked',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$bool);
var _elm_lang$html$Html_Events$targetValue = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'value',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$string);
var _elm_lang$html$Html_Events$defaultOptions = _elm_lang$virtual_dom$VirtualDom$defaultOptions;
var _elm_lang$html$Html_Events$onWithOptions = _elm_lang$virtual_dom$VirtualDom$onWithOptions;
var _elm_lang$html$Html_Events$on = _elm_lang$virtual_dom$VirtualDom$on;
var _elm_lang$html$Html_Events$onFocus = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'focus',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onBlur = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'blur',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onSubmitOptions = _elm_lang$core$Native_Utils.update(
	_elm_lang$html$Html_Events$defaultOptions,
	{preventDefault: true});
var _elm_lang$html$Html_Events$onSubmit = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'submit',
		_elm_lang$html$Html_Events$onSubmitOptions,
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onCheck = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'change',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetChecked));
};
var _elm_lang$html$Html_Events$onInput = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'input',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetValue));
};
var _elm_lang$html$Html_Events$onMouseOut = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseout',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseOver = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseover',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseLeave = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseleave',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseEnter = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseenter',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseUp = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseup',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseDown = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mousedown',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onDoubleClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'dblclick',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'click',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});

var _elm_lang$html$Html_Keyed$node = _elm_lang$virtual_dom$VirtualDom$keyedNode;
var _elm_lang$html$Html_Keyed$ol = _elm_lang$html$Html_Keyed$node('ol');
var _elm_lang$html$Html_Keyed$ul = _elm_lang$html$Html_Keyed$node('ul');

var _elm_lang$http$Native_Http = function() {


// ENCODING AND DECODING

function encodeUri(string)
{
	return encodeURIComponent(string);
}

function decodeUri(string)
{
	try
	{
		return _elm_lang$core$Maybe$Just(decodeURIComponent(string));
	}
	catch(e)
	{
		return _elm_lang$core$Maybe$Nothing;
	}
}


// SEND REQUEST

function toTask(request, maybeProgress)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var xhr = new XMLHttpRequest();

		configureProgress(xhr, maybeProgress);

		xhr.addEventListener('error', function() {
			callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'NetworkError' }));
		});
		xhr.addEventListener('timeout', function() {
			callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'Timeout' }));
		});
		xhr.addEventListener('load', function() {
			callback(handleResponse(xhr, request.expect.responseToResult));
		});

		try
		{
			xhr.open(request.method, request.url, true);
		}
		catch (e)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail({ ctor: 'BadUrl', _0: request.url }));
		}

		configureRequest(xhr, request);
		send(xhr, request.body);

		return function() { xhr.abort(); };
	});
}

function configureProgress(xhr, maybeProgress)
{
	if (maybeProgress.ctor === 'Nothing')
	{
		return;
	}

	xhr.addEventListener('progress', function(event) {
		if (!event.lengthComputable)
		{
			return;
		}
		_elm_lang$core$Native_Scheduler.rawSpawn(maybeProgress._0({
			bytes: event.loaded,
			bytesExpected: event.total
		}));
	});
}

function configureRequest(xhr, request)
{
	function setHeader(pair)
	{
		xhr.setRequestHeader(pair._0, pair._1);
	}

	A2(_elm_lang$core$List$map, setHeader, request.headers);
	xhr.responseType = request.expect.responseType;
	xhr.withCredentials = request.withCredentials;

	if (request.timeout.ctor === 'Just')
	{
		xhr.timeout = request.timeout._0;
	}
}

function send(xhr, body)
{
	switch (body.ctor)
	{
		case 'EmptyBody':
			xhr.send();
			return;

		case 'StringBody':
			xhr.setRequestHeader('Content-Type', body._0);
			xhr.send(body._1);
			return;

		case 'FormDataBody':
			xhr.send(body._0);
			return;
	}
}


// RESPONSES

function handleResponse(xhr, responseToResult)
{
	var response = toResponse(xhr);

	if (xhr.status < 200 || 300 <= xhr.status)
	{
		response.body = xhr.responseText;
		return _elm_lang$core$Native_Scheduler.fail({
			ctor: 'BadStatus',
			_0: response
		});
	}

	var result = responseToResult(response);

	if (result.ctor === 'Ok')
	{
		return _elm_lang$core$Native_Scheduler.succeed(result._0);
	}
	else
	{
		response.body = xhr.responseText;
		return _elm_lang$core$Native_Scheduler.fail({
			ctor: 'BadPayload',
			_0: result._0,
			_1: response
		});
	}
}

function toResponse(xhr)
{
	return {
		status: { code: xhr.status, message: xhr.statusText },
		headers: parseHeaders(xhr.getAllResponseHeaders()),
		url: xhr.responseURL,
		body: xhr.response
	};
}

function parseHeaders(rawHeaders)
{
	var headers = _elm_lang$core$Dict$empty;

	if (!rawHeaders)
	{
		return headers;
	}

	var headerPairs = rawHeaders.split('\u000d\u000a');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf('\u003a\u0020');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3(_elm_lang$core$Dict$update, key, function(oldValue) {
				if (oldValue.ctor === 'Just')
				{
					return _elm_lang$core$Maybe$Just(value + ', ' + oldValue._0);
				}
				return _elm_lang$core$Maybe$Just(value);
			}, headers);
		}
	}

	return headers;
}


// EXPECTORS

function expectStringResponse(responseToResult)
{
	return {
		responseType: 'text',
		responseToResult: responseToResult
	};
}

function mapExpect(func, expect)
{
	return {
		responseType: expect.responseType,
		responseToResult: function(response) {
			var convertedResponse = expect.responseToResult(response);
			return A2(_elm_lang$core$Result$map, func, convertedResponse);
		}
	};
}


// BODY

function multipart(parts)
{
	var formData = new FormData();

	while (parts.ctor !== '[]')
	{
		var part = parts._0;
		formData.append(part._0, part._1);
		parts = parts._1;
	}

	return { ctor: 'FormDataBody', _0: formData };
}

return {
	toTask: F2(toTask),
	expectStringResponse: expectStringResponse,
	mapExpect: F2(mapExpect),
	multipart: multipart,
	encodeUri: encodeUri,
	decodeUri: decodeUri
};

}();

var _elm_lang$http$Http_Internal$map = F2(
	function (func, request) {
		return _elm_lang$core$Native_Utils.update(
			request,
			{
				expect: A2(_elm_lang$http$Native_Http.mapExpect, func, request.expect)
			});
	});
var _elm_lang$http$Http_Internal$RawRequest = F7(
	function (a, b, c, d, e, f, g) {
		return {method: a, headers: b, url: c, body: d, expect: e, timeout: f, withCredentials: g};
	});
var _elm_lang$http$Http_Internal$Request = function (a) {
	return {ctor: 'Request', _0: a};
};
var _elm_lang$http$Http_Internal$Expect = {ctor: 'Expect'};
var _elm_lang$http$Http_Internal$FormDataBody = {ctor: 'FormDataBody'};
var _elm_lang$http$Http_Internal$StringBody = F2(
	function (a, b) {
		return {ctor: 'StringBody', _0: a, _1: b};
	});
var _elm_lang$http$Http_Internal$EmptyBody = {ctor: 'EmptyBody'};
var _elm_lang$http$Http_Internal$Header = F2(
	function (a, b) {
		return {ctor: 'Header', _0: a, _1: b};
	});

var _elm_lang$http$Http$decodeUri = _elm_lang$http$Native_Http.decodeUri;
var _elm_lang$http$Http$encodeUri = _elm_lang$http$Native_Http.encodeUri;
var _elm_lang$http$Http$expectStringResponse = _elm_lang$http$Native_Http.expectStringResponse;
var _elm_lang$http$Http$expectJson = function (decoder) {
	return _elm_lang$http$Http$expectStringResponse(
		function (response) {
			return A2(_elm_lang$core$Json_Decode$decodeString, decoder, response.body);
		});
};
var _elm_lang$http$Http$expectString = _elm_lang$http$Http$expectStringResponse(
	function (response) {
		return _elm_lang$core$Result$Ok(response.body);
	});
var _elm_lang$http$Http$multipartBody = _elm_lang$http$Native_Http.multipart;
var _elm_lang$http$Http$stringBody = _elm_lang$http$Http_Internal$StringBody;
var _elm_lang$http$Http$jsonBody = function (value) {
	return A2(
		_elm_lang$http$Http_Internal$StringBody,
		'application/json',
		A2(_elm_lang$core$Json_Encode$encode, 0, value));
};
var _elm_lang$http$Http$emptyBody = _elm_lang$http$Http_Internal$EmptyBody;
var _elm_lang$http$Http$header = _elm_lang$http$Http_Internal$Header;
var _elm_lang$http$Http$request = _elm_lang$http$Http_Internal$Request;
var _elm_lang$http$Http$post = F3(
	function (url, body, decoder) {
		return _elm_lang$http$Http$request(
			{
				method: 'POST',
				headers: {ctor: '[]'},
				url: url,
				body: body,
				expect: _elm_lang$http$Http$expectJson(decoder),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
	});
var _elm_lang$http$Http$get = F2(
	function (url, decoder) {
		return _elm_lang$http$Http$request(
			{
				method: 'GET',
				headers: {ctor: '[]'},
				url: url,
				body: _elm_lang$http$Http$emptyBody,
				expect: _elm_lang$http$Http$expectJson(decoder),
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			});
	});
var _elm_lang$http$Http$getString = function (url) {
	return _elm_lang$http$Http$request(
		{
			method: 'GET',
			headers: {ctor: '[]'},
			url: url,
			body: _elm_lang$http$Http$emptyBody,
			expect: _elm_lang$http$Http$expectString,
			timeout: _elm_lang$core$Maybe$Nothing,
			withCredentials: false
		});
};
var _elm_lang$http$Http$toTask = function (_p0) {
	var _p1 = _p0;
	return A2(_elm_lang$http$Native_Http.toTask, _p1._0, _elm_lang$core$Maybe$Nothing);
};
var _elm_lang$http$Http$send = F2(
	function (resultToMessage, request) {
		return A2(
			_elm_lang$core$Task$attempt,
			resultToMessage,
			_elm_lang$http$Http$toTask(request));
	});
var _elm_lang$http$Http$Response = F4(
	function (a, b, c, d) {
		return {url: a, status: b, headers: c, body: d};
	});
var _elm_lang$http$Http$BadPayload = F2(
	function (a, b) {
		return {ctor: 'BadPayload', _0: a, _1: b};
	});
var _elm_lang$http$Http$BadStatus = function (a) {
	return {ctor: 'BadStatus', _0: a};
};
var _elm_lang$http$Http$NetworkError = {ctor: 'NetworkError'};
var _elm_lang$http$Http$Timeout = {ctor: 'Timeout'};
var _elm_lang$http$Http$BadUrl = function (a) {
	return {ctor: 'BadUrl', _0: a};
};
var _elm_lang$http$Http$StringPart = F2(
	function (a, b) {
		return {ctor: 'StringPart', _0: a, _1: b};
	});
var _elm_lang$http$Http$stringPart = _elm_lang$http$Http$StringPart;

var _elm_lang$keyboard$Keyboard$onSelfMsg = F3(
	function (router, _p0, state) {
		var _p1 = _p0;
		var _p2 = A2(_elm_lang$core$Dict$get, _p1.category, state);
		if (_p2.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var send = function (tagger) {
				return A2(
					_elm_lang$core$Platform$sendToApp,
					router,
					tagger(_p1.keyCode));
			};
			return A2(
				_elm_lang$core$Task$andThen,
				function (_p3) {
					return _elm_lang$core$Task$succeed(state);
				},
				_elm_lang$core$Task$sequence(
					A2(_elm_lang$core$List$map, send, _p2._0.taggers)));
		}
	});
var _elm_lang$keyboard$Keyboard_ops = _elm_lang$keyboard$Keyboard_ops || {};
_elm_lang$keyboard$Keyboard_ops['&>'] = F2(
	function (task1, task2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p4) {
				return task2;
			},
			task1);
	});
var _elm_lang$keyboard$Keyboard$init = _elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty);
var _elm_lang$keyboard$Keyboard$categorizeHelpHelp = F2(
	function (value, maybeValues) {
		var _p5 = maybeValues;
		if (_p5.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Just(
				{
					ctor: '::',
					_0: value,
					_1: {ctor: '[]'}
				});
		} else {
			return _elm_lang$core$Maybe$Just(
				{ctor: '::', _0: value, _1: _p5._0});
		}
	});
var _elm_lang$keyboard$Keyboard$categorizeHelp = F2(
	function (subs, subDict) {
		categorizeHelp:
		while (true) {
			var _p6 = subs;
			if (_p6.ctor === '[]') {
				return subDict;
			} else {
				var _v4 = _p6._1,
					_v5 = A3(
					_elm_lang$core$Dict$update,
					_p6._0._0,
					_elm_lang$keyboard$Keyboard$categorizeHelpHelp(_p6._0._1),
					subDict);
				subs = _v4;
				subDict = _v5;
				continue categorizeHelp;
			}
		}
	});
var _elm_lang$keyboard$Keyboard$categorize = function (subs) {
	return A2(_elm_lang$keyboard$Keyboard$categorizeHelp, subs, _elm_lang$core$Dict$empty);
};
var _elm_lang$keyboard$Keyboard$keyCode = A2(_elm_lang$core$Json_Decode$field, 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$keyboard$Keyboard$subscription = _elm_lang$core$Native_Platform.leaf('Keyboard');
var _elm_lang$keyboard$Keyboard$Watcher = F2(
	function (a, b) {
		return {taggers: a, pid: b};
	});
var _elm_lang$keyboard$Keyboard$Msg = F2(
	function (a, b) {
		return {category: a, keyCode: b};
	});
var _elm_lang$keyboard$Keyboard$onEffects = F3(
	function (router, newSubs, oldState) {
		var rightStep = F3(
			function (category, taggers, task) {
				return A2(
					_elm_lang$core$Task$andThen,
					function (state) {
						return A2(
							_elm_lang$core$Task$andThen,
							function (pid) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$core$Dict$insert,
										category,
										A2(_elm_lang$keyboard$Keyboard$Watcher, taggers, pid),
										state));
							},
							_elm_lang$core$Process$spawn(
								A3(
									_elm_lang$dom$Dom_LowLevel$onDocument,
									category,
									_elm_lang$keyboard$Keyboard$keyCode,
									function (_p7) {
										return A2(
											_elm_lang$core$Platform$sendToSelf,
											router,
											A2(_elm_lang$keyboard$Keyboard$Msg, category, _p7));
									})));
					},
					task);
			});
		var bothStep = F4(
			function (category, _p8, taggers, task) {
				var _p9 = _p8;
				return A2(
					_elm_lang$core$Task$map,
					A2(
						_elm_lang$core$Dict$insert,
						category,
						A2(_elm_lang$keyboard$Keyboard$Watcher, taggers, _p9.pid)),
					task);
			});
		var leftStep = F3(
			function (category, _p10, task) {
				var _p11 = _p10;
				return A2(
					_elm_lang$keyboard$Keyboard_ops['&>'],
					_elm_lang$core$Process$kill(_p11.pid),
					task);
			});
		return A6(
			_elm_lang$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			oldState,
			_elm_lang$keyboard$Keyboard$categorize(newSubs),
			_elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty));
	});
var _elm_lang$keyboard$Keyboard$MySub = F2(
	function (a, b) {
		return {ctor: 'MySub', _0: a, _1: b};
	});
var _elm_lang$keyboard$Keyboard$presses = function (tagger) {
	return _elm_lang$keyboard$Keyboard$subscription(
		A2(_elm_lang$keyboard$Keyboard$MySub, 'keypress', tagger));
};
var _elm_lang$keyboard$Keyboard$downs = function (tagger) {
	return _elm_lang$keyboard$Keyboard$subscription(
		A2(_elm_lang$keyboard$Keyboard$MySub, 'keydown', tagger));
};
var _elm_lang$keyboard$Keyboard$ups = function (tagger) {
	return _elm_lang$keyboard$Keyboard$subscription(
		A2(_elm_lang$keyboard$Keyboard$MySub, 'keyup', tagger));
};
var _elm_lang$keyboard$Keyboard$subMap = F2(
	function (func, _p12) {
		var _p13 = _p12;
		return A2(
			_elm_lang$keyboard$Keyboard$MySub,
			_p13._0,
			function (_p14) {
				return func(
					_p13._1(_p14));
			});
	});
_elm_lang$core$Native_Platform.effectManagers['Keyboard'] = {pkg: 'elm-lang/keyboard', init: _elm_lang$keyboard$Keyboard$init, onEffects: _elm_lang$keyboard$Keyboard$onEffects, onSelfMsg: _elm_lang$keyboard$Keyboard$onSelfMsg, tag: 'sub', subMap: _elm_lang$keyboard$Keyboard$subMap};

var _elm_lang$navigation$Native_Navigation = function() {


// FAKE NAVIGATION

function go(n)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		if (n !== 0)
		{
			history.go(n);
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function pushState(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		history.pushState({}, '', url);
		callback(_elm_lang$core$Native_Scheduler.succeed(getLocation()));
	});
}

function replaceState(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		history.replaceState({}, '', url);
		callback(_elm_lang$core$Native_Scheduler.succeed(getLocation()));
	});
}


// REAL NAVIGATION

function reloadPage(skipCache)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		document.location.reload(skipCache);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function setLocation(url)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		try
		{
			window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			document.location.reload(false);
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


// GET LOCATION

function getLocation()
{
	var location = document.location;

	return {
		href: location.href,
		host: location.host,
		hostname: location.hostname,
		protocol: location.protocol,
		origin: location.origin,
		port_: location.port,
		pathname: location.pathname,
		search: location.search,
		hash: location.hash,
		username: location.username,
		password: location.password
	};
}


// DETECT IE11 PROBLEMS

function isInternetExplorer11()
{
	return window.navigator.userAgent.indexOf('Trident') !== -1;
}


return {
	go: go,
	setLocation: setLocation,
	reloadPage: reloadPage,
	pushState: pushState,
	replaceState: replaceState,
	getLocation: getLocation,
	isInternetExplorer11: isInternetExplorer11
};

}();

var _elm_lang$navigation$Navigation$replaceState = _elm_lang$navigation$Native_Navigation.replaceState;
var _elm_lang$navigation$Navigation$pushState = _elm_lang$navigation$Native_Navigation.pushState;
var _elm_lang$navigation$Navigation$go = _elm_lang$navigation$Native_Navigation.go;
var _elm_lang$navigation$Navigation$reloadPage = _elm_lang$navigation$Native_Navigation.reloadPage;
var _elm_lang$navigation$Navigation$setLocation = _elm_lang$navigation$Native_Navigation.setLocation;
var _elm_lang$navigation$Navigation_ops = _elm_lang$navigation$Navigation_ops || {};
_elm_lang$navigation$Navigation_ops['&>'] = F2(
	function (task1, task2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p0) {
				return task2;
			},
			task1);
	});
var _elm_lang$navigation$Navigation$notify = F3(
	function (router, subs, location) {
		var send = function (_p1) {
			var _p2 = _p1;
			return A2(
				_elm_lang$core$Platform$sendToApp,
				router,
				_p2._0(location));
		};
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Task$sequence(
				A2(_elm_lang$core$List$map, send, subs)),
			_elm_lang$core$Task$succeed(
				{ctor: '_Tuple0'}));
	});
var _elm_lang$navigation$Navigation$cmdHelp = F3(
	function (router, subs, cmd) {
		var _p3 = cmd;
		switch (_p3.ctor) {
			case 'Jump':
				return _elm_lang$navigation$Navigation$go(_p3._0);
			case 'New':
				return A2(
					_elm_lang$core$Task$andThen,
					A2(_elm_lang$navigation$Navigation$notify, router, subs),
					_elm_lang$navigation$Navigation$pushState(_p3._0));
			case 'Modify':
				return A2(
					_elm_lang$core$Task$andThen,
					A2(_elm_lang$navigation$Navigation$notify, router, subs),
					_elm_lang$navigation$Navigation$replaceState(_p3._0));
			case 'Visit':
				return _elm_lang$navigation$Navigation$setLocation(_p3._0);
			default:
				return _elm_lang$navigation$Navigation$reloadPage(_p3._0);
		}
	});
var _elm_lang$navigation$Navigation$killPopWatcher = function (popWatcher) {
	var _p4 = popWatcher;
	if (_p4.ctor === 'Normal') {
		return _elm_lang$core$Process$kill(_p4._0);
	} else {
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Process$kill(_p4._0),
			_elm_lang$core$Process$kill(_p4._1));
	}
};
var _elm_lang$navigation$Navigation$onSelfMsg = F3(
	function (router, location, state) {
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			A3(_elm_lang$navigation$Navigation$notify, router, state.subs, location),
			_elm_lang$core$Task$succeed(state));
	});
var _elm_lang$navigation$Navigation$subscription = _elm_lang$core$Native_Platform.leaf('Navigation');
var _elm_lang$navigation$Navigation$command = _elm_lang$core$Native_Platform.leaf('Navigation');
var _elm_lang$navigation$Navigation$Location = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return {href: a, host: b, hostname: c, protocol: d, origin: e, port_: f, pathname: g, search: h, hash: i, username: j, password: k};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$navigation$Navigation$State = F2(
	function (a, b) {
		return {subs: a, popWatcher: b};
	});
var _elm_lang$navigation$Navigation$init = _elm_lang$core$Task$succeed(
	A2(
		_elm_lang$navigation$Navigation$State,
		{ctor: '[]'},
		_elm_lang$core$Maybe$Nothing));
var _elm_lang$navigation$Navigation$Reload = function (a) {
	return {ctor: 'Reload', _0: a};
};
var _elm_lang$navigation$Navigation$reload = _elm_lang$navigation$Navigation$command(
	_elm_lang$navigation$Navigation$Reload(false));
var _elm_lang$navigation$Navigation$reloadAndSkipCache = _elm_lang$navigation$Navigation$command(
	_elm_lang$navigation$Navigation$Reload(true));
var _elm_lang$navigation$Navigation$Visit = function (a) {
	return {ctor: 'Visit', _0: a};
};
var _elm_lang$navigation$Navigation$load = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Visit(url));
};
var _elm_lang$navigation$Navigation$Modify = function (a) {
	return {ctor: 'Modify', _0: a};
};
var _elm_lang$navigation$Navigation$modifyUrl = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Modify(url));
};
var _elm_lang$navigation$Navigation$New = function (a) {
	return {ctor: 'New', _0: a};
};
var _elm_lang$navigation$Navigation$newUrl = function (url) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$New(url));
};
var _elm_lang$navigation$Navigation$Jump = function (a) {
	return {ctor: 'Jump', _0: a};
};
var _elm_lang$navigation$Navigation$back = function (n) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Jump(0 - n));
};
var _elm_lang$navigation$Navigation$forward = function (n) {
	return _elm_lang$navigation$Navigation$command(
		_elm_lang$navigation$Navigation$Jump(n));
};
var _elm_lang$navigation$Navigation$cmdMap = F2(
	function (_p5, myCmd) {
		var _p6 = myCmd;
		switch (_p6.ctor) {
			case 'Jump':
				return _elm_lang$navigation$Navigation$Jump(_p6._0);
			case 'New':
				return _elm_lang$navigation$Navigation$New(_p6._0);
			case 'Modify':
				return _elm_lang$navigation$Navigation$Modify(_p6._0);
			case 'Visit':
				return _elm_lang$navigation$Navigation$Visit(_p6._0);
			default:
				return _elm_lang$navigation$Navigation$Reload(_p6._0);
		}
	});
var _elm_lang$navigation$Navigation$Monitor = function (a) {
	return {ctor: 'Monitor', _0: a};
};
var _elm_lang$navigation$Navigation$program = F2(
	function (locationToMessage, stuff) {
		var init = stuff.init(
			_elm_lang$navigation$Native_Navigation.getLocation(
				{ctor: '_Tuple0'}));
		var subs = function (model) {
			return _elm_lang$core$Platform_Sub$batch(
				{
					ctor: '::',
					_0: _elm_lang$navigation$Navigation$subscription(
						_elm_lang$navigation$Navigation$Monitor(locationToMessage)),
					_1: {
						ctor: '::',
						_0: stuff.subscriptions(model),
						_1: {ctor: '[]'}
					}
				});
		};
		return _elm_lang$html$Html$program(
			{init: init, view: stuff.view, update: stuff.update, subscriptions: subs});
	});
var _elm_lang$navigation$Navigation$programWithFlags = F2(
	function (locationToMessage, stuff) {
		var init = function (flags) {
			return A2(
				stuff.init,
				flags,
				_elm_lang$navigation$Native_Navigation.getLocation(
					{ctor: '_Tuple0'}));
		};
		var subs = function (model) {
			return _elm_lang$core$Platform_Sub$batch(
				{
					ctor: '::',
					_0: _elm_lang$navigation$Navigation$subscription(
						_elm_lang$navigation$Navigation$Monitor(locationToMessage)),
					_1: {
						ctor: '::',
						_0: stuff.subscriptions(model),
						_1: {ctor: '[]'}
					}
				});
		};
		return _elm_lang$html$Html$programWithFlags(
			{init: init, view: stuff.view, update: stuff.update, subscriptions: subs});
	});
var _elm_lang$navigation$Navigation$subMap = F2(
	function (func, _p7) {
		var _p8 = _p7;
		return _elm_lang$navigation$Navigation$Monitor(
			function (_p9) {
				return func(
					_p8._0(_p9));
			});
	});
var _elm_lang$navigation$Navigation$InternetExplorer = F2(
	function (a, b) {
		return {ctor: 'InternetExplorer', _0: a, _1: b};
	});
var _elm_lang$navigation$Navigation$Normal = function (a) {
	return {ctor: 'Normal', _0: a};
};
var _elm_lang$navigation$Navigation$spawnPopWatcher = function (router) {
	var reportLocation = function (_p10) {
		return A2(
			_elm_lang$core$Platform$sendToSelf,
			router,
			_elm_lang$navigation$Native_Navigation.getLocation(
				{ctor: '_Tuple0'}));
	};
	return _elm_lang$navigation$Native_Navigation.isInternetExplorer11(
		{ctor: '_Tuple0'}) ? A3(
		_elm_lang$core$Task$map2,
		_elm_lang$navigation$Navigation$InternetExplorer,
		_elm_lang$core$Process$spawn(
			A3(_elm_lang$dom$Dom_LowLevel$onWindow, 'popstate', _elm_lang$core$Json_Decode$value, reportLocation)),
		_elm_lang$core$Process$spawn(
			A3(_elm_lang$dom$Dom_LowLevel$onWindow, 'hashchange', _elm_lang$core$Json_Decode$value, reportLocation))) : A2(
		_elm_lang$core$Task$map,
		_elm_lang$navigation$Navigation$Normal,
		_elm_lang$core$Process$spawn(
			A3(_elm_lang$dom$Dom_LowLevel$onWindow, 'popstate', _elm_lang$core$Json_Decode$value, reportLocation)));
};
var _elm_lang$navigation$Navigation$onEffects = F4(
	function (router, cmds, subs, _p11) {
		var _p12 = _p11;
		var _p15 = _p12.popWatcher;
		var stepState = function () {
			var _p13 = {ctor: '_Tuple2', _0: subs, _1: _p15};
			_v6_2:
			do {
				if (_p13._0.ctor === '[]') {
					if (_p13._1.ctor === 'Just') {
						return A2(
							_elm_lang$navigation$Navigation_ops['&>'],
							_elm_lang$navigation$Navigation$killPopWatcher(_p13._1._0),
							_elm_lang$core$Task$succeed(
								A2(_elm_lang$navigation$Navigation$State, subs, _elm_lang$core$Maybe$Nothing)));
					} else {
						break _v6_2;
					}
				} else {
					if (_p13._1.ctor === 'Nothing') {
						return A2(
							_elm_lang$core$Task$map,
							function (_p14) {
								return A2(
									_elm_lang$navigation$Navigation$State,
									subs,
									_elm_lang$core$Maybe$Just(_p14));
							},
							_elm_lang$navigation$Navigation$spawnPopWatcher(router));
					} else {
						break _v6_2;
					}
				}
			} while(false);
			return _elm_lang$core$Task$succeed(
				A2(_elm_lang$navigation$Navigation$State, subs, _p15));
		}();
		return A2(
			_elm_lang$navigation$Navigation_ops['&>'],
			_elm_lang$core$Task$sequence(
				A2(
					_elm_lang$core$List$map,
					A2(_elm_lang$navigation$Navigation$cmdHelp, router, subs),
					cmds)),
			stepState);
	});
_elm_lang$core$Native_Platform.effectManagers['Navigation'] = {pkg: 'elm-lang/navigation', init: _elm_lang$navigation$Navigation$init, onEffects: _elm_lang$navigation$Navigation$onEffects, onSelfMsg: _elm_lang$navigation$Navigation$onSelfMsg, tag: 'fx', cmdMap: _elm_lang$navigation$Navigation$cmdMap, subMap: _elm_lang$navigation$Navigation$subMap};

var _elm_lang$websocket$Native_WebSocket = function() {

function open(url, settings)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		try
		{
			var socket = new WebSocket(url);
			socket.elm_web_socket = true;
		}
		catch(err)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail({
				ctor: err.name === 'SecurityError' ? 'BadSecurity' : 'BadArgs',
				_0: err.message
			}));
		}

		socket.addEventListener("open", function(event) {
			callback(_elm_lang$core$Native_Scheduler.succeed(socket));
		});

		socket.addEventListener("message", function(event) {
			_elm_lang$core$Native_Scheduler.rawSpawn(A2(settings.onMessage, socket, event.data));
		});

		socket.addEventListener("close", function(event) {
			_elm_lang$core$Native_Scheduler.rawSpawn(settings.onClose({
				code: event.code,
				reason: event.reason,
				wasClean: event.wasClean
			}));
		});

		return function()
		{
			if (socket && socket.close)
			{
				socket.close();
			}
		};
	});
}

function send(socket, string)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var result =
			socket.readyState === WebSocket.OPEN
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just({ ctor: 'NotOpen' });

		try
		{
			socket.send(string);
		}
		catch(err)
		{
			result = _elm_lang$core$Maybe$Just({ ctor: 'BadString' });
		}

		callback(_elm_lang$core$Native_Scheduler.succeed(result));
	});
}

function close(code, reason, socket)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		try
		{
			socket.close(code, reason);
		}
		catch(err)
		{
			return callback(_elm_lang$core$Native_Scheduler.fail(_elm_lang$core$Maybe$Just({
				ctor: err.name === 'SyntaxError' ? 'BadReason' : 'BadCode'
			})));
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Maybe$Nothing));
	});
}

function bytesQueued(socket)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		callback(_elm_lang$core$Native_Scheduler.succeed(socket.bufferedAmount));
	});
}

return {
	open: F2(open),
	send: F2(send),
	close: F3(close),
	bytesQueued: bytesQueued
};

}();

var _elm_lang$websocket$WebSocket_LowLevel$bytesQueued = _elm_lang$websocket$Native_WebSocket.bytesQueued;
var _elm_lang$websocket$WebSocket_LowLevel$send = _elm_lang$websocket$Native_WebSocket.send;
var _elm_lang$websocket$WebSocket_LowLevel$closeWith = _elm_lang$websocket$Native_WebSocket.close;
var _elm_lang$websocket$WebSocket_LowLevel$close = function (socket) {
	return A2(
		_elm_lang$core$Task$map,
		_elm_lang$core$Basics$always(
			{ctor: '_Tuple0'}),
		A3(_elm_lang$websocket$WebSocket_LowLevel$closeWith, 1000, '', socket));
};
var _elm_lang$websocket$WebSocket_LowLevel$open = _elm_lang$websocket$Native_WebSocket.open;
var _elm_lang$websocket$WebSocket_LowLevel$Settings = F2(
	function (a, b) {
		return {onMessage: a, onClose: b};
	});
var _elm_lang$websocket$WebSocket_LowLevel$WebSocket = {ctor: 'WebSocket'};
var _elm_lang$websocket$WebSocket_LowLevel$BadArgs = {ctor: 'BadArgs'};
var _elm_lang$websocket$WebSocket_LowLevel$BadSecurity = {ctor: 'BadSecurity'};
var _elm_lang$websocket$WebSocket_LowLevel$BadReason = {ctor: 'BadReason'};
var _elm_lang$websocket$WebSocket_LowLevel$BadCode = {ctor: 'BadCode'};
var _elm_lang$websocket$WebSocket_LowLevel$BadString = {ctor: 'BadString'};
var _elm_lang$websocket$WebSocket_LowLevel$NotOpen = {ctor: 'NotOpen'};

var _evancz$url_parser$UrlParser$toKeyValuePair = function (segment) {
	var _p0 = A2(_elm_lang$core$String$split, '=', segment);
	if (((_p0.ctor === '::') && (_p0._1.ctor === '::')) && (_p0._1._1.ctor === '[]')) {
		return A3(
			_elm_lang$core$Maybe$map2,
			F2(
				function (v0, v1) {
					return {ctor: '_Tuple2', _0: v0, _1: v1};
				}),
			_elm_lang$http$Http$decodeUri(_p0._0),
			_elm_lang$http$Http$decodeUri(_p0._1._0));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _evancz$url_parser$UrlParser$parseParams = function (queryString) {
	return _elm_lang$core$Dict$fromList(
		A2(
			_elm_lang$core$List$filterMap,
			_evancz$url_parser$UrlParser$toKeyValuePair,
			A2(
				_elm_lang$core$String$split,
				'&',
				A2(_elm_lang$core$String$dropLeft, 1, queryString))));
};
var _evancz$url_parser$UrlParser$splitUrl = function (url) {
	var _p1 = A2(_elm_lang$core$String$split, '/', url);
	if ((_p1.ctor === '::') && (_p1._0 === '')) {
		return _p1._1;
	} else {
		return _p1;
	}
};
var _evancz$url_parser$UrlParser$parseHelp = function (states) {
	parseHelp:
	while (true) {
		var _p2 = states;
		if (_p2.ctor === '[]') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			var _p4 = _p2._0;
			var _p3 = _p4.unvisited;
			if (_p3.ctor === '[]') {
				return _elm_lang$core$Maybe$Just(_p4.value);
			} else {
				if ((_p3._0 === '') && (_p3._1.ctor === '[]')) {
					return _elm_lang$core$Maybe$Just(_p4.value);
				} else {
					var _v4 = _p2._1;
					states = _v4;
					continue parseHelp;
				}
			}
		}
	}
};
var _evancz$url_parser$UrlParser$parse = F3(
	function (_p5, url, params) {
		var _p6 = _p5;
		return _evancz$url_parser$UrlParser$parseHelp(
			_p6._0(
				{
					visited: {ctor: '[]'},
					unvisited: _evancz$url_parser$UrlParser$splitUrl(url),
					params: params,
					value: _elm_lang$core$Basics$identity
				}));
	});
var _evancz$url_parser$UrlParser$parseHash = F2(
	function (parser, location) {
		return A3(
			_evancz$url_parser$UrlParser$parse,
			parser,
			A2(_elm_lang$core$String$dropLeft, 1, location.hash),
			_evancz$url_parser$UrlParser$parseParams(location.search));
	});
var _evancz$url_parser$UrlParser$parsePath = F2(
	function (parser, location) {
		return A3(
			_evancz$url_parser$UrlParser$parse,
			parser,
			location.pathname,
			_evancz$url_parser$UrlParser$parseParams(location.search));
	});
var _evancz$url_parser$UrlParser$intParamHelp = function (maybeValue) {
	var _p7 = maybeValue;
	if (_p7.ctor === 'Nothing') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		return _elm_lang$core$Result$toMaybe(
			_elm_lang$core$String$toInt(_p7._0));
	}
};
var _evancz$url_parser$UrlParser$mapHelp = F2(
	function (func, _p8) {
		var _p9 = _p8;
		return {
			visited: _p9.visited,
			unvisited: _p9.unvisited,
			params: _p9.params,
			value: func(_p9.value)
		};
	});
var _evancz$url_parser$UrlParser$State = F4(
	function (a, b, c, d) {
		return {visited: a, unvisited: b, params: c, value: d};
	});
var _evancz$url_parser$UrlParser$Parser = function (a) {
	return {ctor: 'Parser', _0: a};
};
var _evancz$url_parser$UrlParser$s = function (str) {
	return _evancz$url_parser$UrlParser$Parser(
		function (_p10) {
			var _p11 = _p10;
			var _p12 = _p11.unvisited;
			if (_p12.ctor === '[]') {
				return {ctor: '[]'};
			} else {
				var _p13 = _p12._0;
				return _elm_lang$core$Native_Utils.eq(_p13, str) ? {
					ctor: '::',
					_0: A4(
						_evancz$url_parser$UrlParser$State,
						{ctor: '::', _0: _p13, _1: _p11.visited},
						_p12._1,
						_p11.params,
						_p11.value),
					_1: {ctor: '[]'}
				} : {ctor: '[]'};
			}
		});
};
var _evancz$url_parser$UrlParser$custom = F2(
	function (tipe, stringToSomething) {
		return _evancz$url_parser$UrlParser$Parser(
			function (_p14) {
				var _p15 = _p14;
				var _p16 = _p15.unvisited;
				if (_p16.ctor === '[]') {
					return {ctor: '[]'};
				} else {
					var _p18 = _p16._0;
					var _p17 = stringToSomething(_p18);
					if (_p17.ctor === 'Ok') {
						return {
							ctor: '::',
							_0: A4(
								_evancz$url_parser$UrlParser$State,
								{ctor: '::', _0: _p18, _1: _p15.visited},
								_p16._1,
								_p15.params,
								_p15.value(_p17._0)),
							_1: {ctor: '[]'}
						};
					} else {
						return {ctor: '[]'};
					}
				}
			});
	});
var _evancz$url_parser$UrlParser$string = A2(_evancz$url_parser$UrlParser$custom, 'STRING', _elm_lang$core$Result$Ok);
var _evancz$url_parser$UrlParser$int = A2(_evancz$url_parser$UrlParser$custom, 'NUMBER', _elm_lang$core$String$toInt);
var _evancz$url_parser$UrlParser_ops = _evancz$url_parser$UrlParser_ops || {};
_evancz$url_parser$UrlParser_ops['</>'] = F2(
	function (_p20, _p19) {
		var _p21 = _p20;
		var _p22 = _p19;
		return _evancz$url_parser$UrlParser$Parser(
			function (state) {
				return A2(
					_elm_lang$core$List$concatMap,
					_p22._0,
					_p21._0(state));
			});
	});
var _evancz$url_parser$UrlParser$map = F2(
	function (subValue, _p23) {
		var _p24 = _p23;
		return _evancz$url_parser$UrlParser$Parser(
			function (_p25) {
				var _p26 = _p25;
				return A2(
					_elm_lang$core$List$map,
					_evancz$url_parser$UrlParser$mapHelp(_p26.value),
					_p24._0(
						{visited: _p26.visited, unvisited: _p26.unvisited, params: _p26.params, value: subValue}));
			});
	});
var _evancz$url_parser$UrlParser$oneOf = function (parsers) {
	return _evancz$url_parser$UrlParser$Parser(
		function (state) {
			return A2(
				_elm_lang$core$List$concatMap,
				function (_p27) {
					var _p28 = _p27;
					return _p28._0(state);
				},
				parsers);
		});
};
var _evancz$url_parser$UrlParser$top = _evancz$url_parser$UrlParser$Parser(
	function (state) {
		return {
			ctor: '::',
			_0: state,
			_1: {ctor: '[]'}
		};
	});
var _evancz$url_parser$UrlParser_ops = _evancz$url_parser$UrlParser_ops || {};
_evancz$url_parser$UrlParser_ops['<?>'] = F2(
	function (_p30, _p29) {
		var _p31 = _p30;
		var _p32 = _p29;
		return _evancz$url_parser$UrlParser$Parser(
			function (state) {
				return A2(
					_elm_lang$core$List$concatMap,
					_p32._0,
					_p31._0(state));
			});
	});
var _evancz$url_parser$UrlParser$QueryParser = function (a) {
	return {ctor: 'QueryParser', _0: a};
};
var _evancz$url_parser$UrlParser$customParam = F2(
	function (key, func) {
		return _evancz$url_parser$UrlParser$QueryParser(
			function (_p33) {
				var _p34 = _p33;
				var _p35 = _p34.params;
				return {
					ctor: '::',
					_0: A4(
						_evancz$url_parser$UrlParser$State,
						_p34.visited,
						_p34.unvisited,
						_p35,
						_p34.value(
							func(
								A2(_elm_lang$core$Dict$get, key, _p35)))),
					_1: {ctor: '[]'}
				};
			});
	});
var _evancz$url_parser$UrlParser$stringParam = function (name) {
	return A2(_evancz$url_parser$UrlParser$customParam, name, _elm_lang$core$Basics$identity);
};
var _evancz$url_parser$UrlParser$intParam = function (name) {
	return A2(_evancz$url_parser$UrlParser$customParam, name, _evancz$url_parser$UrlParser$intParamHelp);
};

var _krisajenkins$elm_exts$Exts_Maybe$oneOf = A2(
	_elm_lang$core$List$foldl,
	F2(
		function (x, acc) {
			return (!_elm_lang$core$Native_Utils.eq(acc, _elm_lang$core$Maybe$Nothing)) ? acc : x;
		}),
	_elm_lang$core$Maybe$Nothing);
var _krisajenkins$elm_exts$Exts_Maybe$when = F2(
	function (test, value) {
		return test ? _elm_lang$core$Maybe$Just(value) : _elm_lang$core$Maybe$Nothing;
	});
var _krisajenkins$elm_exts$Exts_Maybe$validate = F2(
	function (predicate, value) {
		return predicate(value) ? _elm_lang$core$Maybe$Just(value) : _elm_lang$core$Maybe$Nothing;
	});
var _krisajenkins$elm_exts$Exts_Maybe$matches = function (predicate) {
	return _elm_lang$core$Maybe$andThen(
		_krisajenkins$elm_exts$Exts_Maybe$validate(predicate));
};
var _krisajenkins$elm_exts$Exts_Maybe$maybeDefault = F2(
	function ($default, x) {
		var _p0 = x;
		if (_p0.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(_p0._0);
		} else {
			return _elm_lang$core$Maybe$Just($default);
		}
	});
var _krisajenkins$elm_exts$Exts_Maybe$join = F3(
	function (f, left, right) {
		var _p1 = {ctor: '_Tuple2', _0: left, _1: right};
		if (((_p1.ctor === '_Tuple2') && (_p1._0.ctor === 'Just')) && (_p1._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(f, _p1._0._0, _p1._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _krisajenkins$elm_exts$Exts_Maybe$catMaybes = _elm_lang$core$List$filterMap(_elm_lang$core$Basics$identity);
var _krisajenkins$elm_exts$Exts_Maybe$mappend = F2(
	function (a, b) {
		var _p2 = {ctor: '_Tuple2', _0: a, _1: b};
		if (_p2._0.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			if (_p2._1.ctor === 'Nothing') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				return _elm_lang$core$Maybe$Just(
					{ctor: '_Tuple2', _0: _p2._0._0, _1: _p2._1._0});
			}
		}
	});
var _krisajenkins$elm_exts$Exts_Maybe$maybe = F2(
	function ($default, f) {
		return function (_p3) {
			return A2(
				_elm_lang$core$Maybe$withDefault,
				$default,
				A2(_elm_lang$core$Maybe$map, f, _p3));
		};
	});
var _krisajenkins$elm_exts$Exts_Maybe$isJust = function (x) {
	var _p4 = x;
	if (_p4.ctor === 'Just') {
		return true;
	} else {
		return false;
	}
};
var _krisajenkins$elm_exts$Exts_Maybe$isNothing = function (_p5) {
	return !_krisajenkins$elm_exts$Exts_Maybe$isJust(_p5);
};

var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops = _saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops || {};
_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'] = F2(
	function (x, f) {
		return A2(_elm_lang$core$Task$andThen, f, x);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops = _saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops || {};
_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'] = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Task$andThen,
			function (_p0) {
				return t2;
			},
			t1);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$statusInfo = function (status) {
	var _p1 = status;
	switch (_p1) {
		case 'ok':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_elm_lang$core$Result$Ok,
				A2(_elm_lang$core$Json_Decode$field, 'response', _elm_lang$core$Json_Decode$value));
		case 'error':
			return A2(
				_elm_lang$core$Json_Decode$map,
				_elm_lang$core$Result$Err,
				A2(_elm_lang$core$Json_Decode$field, 'response', _elm_lang$core$Json_Decode$value));
		default:
			return _elm_lang$core$Json_Decode$fail(
				A2(_elm_lang$core$Basics_ops['++'], status, ' is a not supported status'));
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$decodeReplyPayload = function (value) {
	var result = A2(
		_elm_lang$core$Json_Decode$decodeValue,
		A2(
			_elm_lang$core$Json_Decode$andThen,
			_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$statusInfo,
			A2(_elm_lang$core$Json_Decode$field, 'status', _elm_lang$core$Json_Decode$string)),
		value);
	var _p2 = result;
	if (_p2.ctor === 'Err') {
		var _p3 = _elm_lang$core$Debug$log(_p2._0);
		return _elm_lang$core$Maybe$Nothing;
	} else {
		return _elm_lang$core$Maybe$Just(_p2._0);
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$add = F2(
	function (value, maybeList) {
		var _p4 = maybeList;
		if (_p4.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Just(
				{
					ctor: '::',
					_0: value,
					_1: {ctor: '[]'}
				});
		} else {
			return _elm_lang$core$Maybe$Just(
				{ctor: '::', _0: value, _1: _p4._0});
		}
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$removeIn = F3(
	function (a, b, dict) {
		var remove = function (maybeDict_) {
			var _p5 = maybeDict_;
			if (_p5.ctor === 'Nothing') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var newDict = A2(_elm_lang$core$Dict$remove, b, _p5._0);
				return _elm_lang$core$Dict$isEmpty(newDict) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(newDict);
			}
		};
		return A3(_elm_lang$core$Dict$update, a, remove, dict);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$insertIn = F4(
	function (a, b, value, dict) {
		var update_ = function (maybeValue) {
			var _p6 = maybeValue;
			if (_p6.ctor === 'Nothing') {
				return _elm_lang$core$Maybe$Just(
					A2(_elm_lang$core$Dict$singleton, b, value));
			} else {
				return _elm_lang$core$Maybe$Just(
					A3(_elm_lang$core$Dict$insert, b, value, _p6._0));
			}
		};
		return A3(_elm_lang$core$Dict$update, a, update_, dict);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$updateIn = F4(
	function (a, b, update, dict) {
		var update_ = function (maybeDict) {
			var dict_ = A3(
				_elm_lang$core$Dict$update,
				b,
				update,
				A2(_elm_lang$core$Maybe$withDefault, _elm_lang$core$Dict$empty, maybeDict));
			return _elm_lang$core$Dict$isEmpty(dict_) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(dict_);
		};
		return A3(_elm_lang$core$Dict$update, a, update_, dict);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$getIn = F3(
	function (a, b, dict) {
		return A2(
			_elm_lang$core$Maybe$andThen,
			_elm_lang$core$Dict$get(b),
			A2(_elm_lang$core$Dict$get, a, dict));
	});

var _saschatimme$elm_phoenix$Phoenix_Push$map = F2(
	function (func, push) {
		var f = _elm_lang$core$Maybe$map(
			F2(
				function (x, y) {
					return function (_p0) {
						return x(
							y(_p0));
					};
				})(func));
		return _elm_lang$core$Native_Utils.update(
			push,
			{
				onOk: f(push.onOk),
				onError: f(push.onError)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Push$onError = F2(
	function (cb, push) {
		return _elm_lang$core$Native_Utils.update(
			push,
			{
				onError: _elm_lang$core$Maybe$Just(cb)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Push$onOk = F2(
	function (cb, push) {
		return _elm_lang$core$Native_Utils.update(
			push,
			{
				onOk: _elm_lang$core$Maybe$Just(cb)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Push$withPayload = F2(
	function (payload, push) {
		return _elm_lang$core$Native_Utils.update(
			push,
			{payload: payload});
	});
var _saschatimme$elm_phoenix$Phoenix_Push$PhoenixPush = F5(
	function (a, b, c, d, e) {
		return {topic: a, event: b, payload: c, onOk: d, onError: e};
	});
var _saschatimme$elm_phoenix$Phoenix_Push$init = F2(
	function (topic, event) {
		return A5(
			_saschatimme$elm_phoenix$Phoenix_Push$PhoenixPush,
			topic,
			event,
			_elm_lang$core$Json_Encode$object(
				{ctor: '[]'}),
			_elm_lang$core$Maybe$Nothing,
			_elm_lang$core$Maybe$Nothing);
	});

var _saschatimme$elm_phoenix$Phoenix_Internal_Message$encode = function (_p0) {
	var _p1 = _p0;
	return A2(
		_elm_lang$core$Json_Encode$encode,
		0,
		_elm_lang$core$Json_Encode$object(
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'topic',
					_1: _elm_lang$core$Json_Encode$string(_p1.topic)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'event',
						_1: _elm_lang$core$Json_Encode$string(_p1.event)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: 'ref',
							_1: A2(
								_elm_lang$core$Maybe$withDefault,
								_elm_lang$core$Json_Encode$null,
								A2(_elm_lang$core$Maybe$map, _elm_lang$core$Json_Encode$int, _p1.ref))
						},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'payload', _1: _p1.payload},
							_1: {ctor: '[]'}
						}
					}
				}
			}));
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Message$ref = F2(
	function (ref_, message) {
		return _elm_lang$core$Native_Utils.update(
			message,
			{
				ref: _elm_lang$core$Maybe$Just(ref_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Message$payload = F2(
	function (payload_, message) {
		return _elm_lang$core$Native_Utils.update(
			message,
			{payload: payload_});
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Message$Message = F4(
	function (a, b, c, d) {
		return {topic: a, event: b, payload: c, ref: d};
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Message$init = F2(
	function (topic, event) {
		return A4(
			_saschatimme$elm_phoenix$Phoenix_Internal_Message$Message,
			topic,
			event,
			_elm_lang$core$Json_Encode$object(
				{ctor: '[]'}),
			_elm_lang$core$Maybe$Nothing);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Message$fromPush = function (push) {
	return A2(
		_saschatimme$elm_phoenix$Phoenix_Internal_Message$payload,
		push.payload,
		A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$init, push.topic, push.event));
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Message$decode = function (msg) {
	var decoder = A5(
		_elm_lang$core$Json_Decode$map4,
		_saschatimme$elm_phoenix$Phoenix_Internal_Message$Message,
		A2(_elm_lang$core$Json_Decode$field, 'topic', _elm_lang$core$Json_Decode$string),
		A2(_elm_lang$core$Json_Decode$field, 'event', _elm_lang$core$Json_Decode$string),
		A2(_elm_lang$core$Json_Decode$field, 'payload', _elm_lang$core$Json_Decode$value),
		A2(
			_elm_lang$core$Json_Decode$field,
			'ref',
			_elm_lang$core$Json_Decode$oneOf(
				{
					ctor: '::',
					_0: A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, _elm_lang$core$Json_Decode$int),
					_1: {
						ctor: '::',
						_0: _elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
						_1: {ctor: '[]'}
					}
				})));
	return A2(_elm_lang$core$Json_Decode$decodeString, decoder, msg);
};

var _saschatimme$elm_phoenix$Phoenix_Channel$withDebug = function (channel) {
	return _elm_lang$core$Native_Utils.update(
		channel,
		{debug: true});
};
var _saschatimme$elm_phoenix$Phoenix_Channel$map = F2(
	function (func, chan) {
		var f = _elm_lang$core$Maybe$map(
			F2(
				function (x, y) {
					return function (_p0) {
						return x(
							y(_p0));
					};
				})(func));
		var channel = _elm_lang$core$Native_Utils.update(
			chan,
			{
				onJoin: f(chan.onJoin),
				onJoinError: f(chan.onJoinError),
				onError: A2(_elm_lang$core$Maybe$map, func, chan.onError),
				onDisconnect: A2(_elm_lang$core$Maybe$map, func, chan.onDisconnect),
				onRejoin: f(chan.onRejoin),
				onLeave: f(chan.onLeave),
				onLeaveError: f(chan.onLeaveError),
				on: A2(
					_elm_lang$core$Dict$map,
					F2(
						function (_p1, a) {
							return function (_p2) {
								return func(
									a(_p2));
							};
						}),
					chan.on)
			});
		return channel;
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onLeaveError = F2(
	function (onLeaveError_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				onLeaveError: _elm_lang$core$Maybe$Just(onLeaveError_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onLeave = F2(
	function (onLeave_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				onLeave: _elm_lang$core$Maybe$Just(onLeave_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onRejoin = F2(
	function (onRejoin_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				onRejoin: _elm_lang$core$Maybe$Just(onRejoin_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onDisconnect = F2(
	function (onDisconnect_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				onDisconnect: _elm_lang$core$Maybe$Just(onDisconnect_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onError = F2(
	function (onError_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				onError: _elm_lang$core$Maybe$Just(onError_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onJoinError = F2(
	function (onJoinError_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				onJoinError: _elm_lang$core$Maybe$Just(onJoinError_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$onJoin = F2(
	function (onJoin_, chan) {
		var _p3 = chan.onRejoin;
		if (_p3.ctor === 'Nothing') {
			return _elm_lang$core$Native_Utils.update(
				chan,
				{
					onJoin: _elm_lang$core$Maybe$Just(onJoin_),
					onRejoin: _elm_lang$core$Maybe$Just(onJoin_)
				});
		} else {
			return _elm_lang$core$Native_Utils.update(
				chan,
				{
					onJoin: _elm_lang$core$Maybe$Just(onJoin_)
				});
		}
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$on = F3(
	function (event, cb, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				on: A3(_elm_lang$core$Dict$insert, event, cb, chan.on)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$withPayload = F2(
	function (payload_, chan) {
		return _elm_lang$core$Native_Utils.update(
			chan,
			{
				payload: _elm_lang$core$Maybe$Just(payload_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Channel$init = function (topic) {
	return {topic: topic, payload: _elm_lang$core$Maybe$Nothing, onJoin: _elm_lang$core$Maybe$Nothing, onJoinError: _elm_lang$core$Maybe$Nothing, onDisconnect: _elm_lang$core$Maybe$Nothing, onError: _elm_lang$core$Maybe$Nothing, onRejoin: _elm_lang$core$Maybe$Nothing, onLeave: _elm_lang$core$Maybe$Nothing, onLeaveError: _elm_lang$core$Maybe$Nothing, on: _elm_lang$core$Dict$empty, debug: false};
};
var _saschatimme$elm_phoenix$Phoenix_Channel$PhoenixChannel = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return {topic: a, payload: b, onJoin: c, onJoinError: d, onDisconnect: e, onError: f, onRejoin: g, onLeave: h, onLeaveError: i, on: j, debug: k};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};

var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$get = F3(
	function (endpoint, topic, channelsDict) {
		return A3(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$getIn, endpoint, topic, channelsDict);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$getState = F3(
	function (endpoint, topic, channelsDict) {
		return A2(
			_elm_lang$core$Maybe$map,
			function (_p0) {
				var _p1 = _p0;
				return _p1.state;
			},
			A3(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$get, endpoint, topic, channelsDict));
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$leaveMessage = function (_p2) {
	var _p3 = _p2;
	return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$init, _p3.channel.topic, 'phx_leave');
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$joinMessage = function (_p4) {
	var _p5 = _p4;
	var _p7 = _p5.channel;
	var base = A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$init, _p7.topic, 'phx_join');
	var _p6 = _p7.payload;
	if (_p6.ctor === 'Nothing') {
		return base;
	} else {
		return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$payload, _p6._0, base);
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel = F2(
	function (a, b) {
		return {state: a, channel: b};
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$map = F2(
	function (func, _p8) {
		var _p9 = _p8;
		return A2(
			_saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel,
			_p9.state,
			A2(_saschatimme$elm_phoenix$Phoenix_Channel$map, func, _p9.channel));
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateState = F2(
	function (state, internalChannel) {
		if (internalChannel.channel.debug) {
			var _p10 = function () {
				var _p11 = {ctor: '_Tuple2', _0: state, _1: internalChannel.state};
				_v5_5:
				do {
					if (_p11.ctor === '_Tuple2') {
						switch (_p11._0.ctor) {
							case 'Closed':
								if (_p11._1.ctor === 'Closed') {
									return state;
								} else {
									break _v5_5;
								}
							case 'Joining':
								if (_p11._1.ctor === 'Joining') {
									return state;
								} else {
									break _v5_5;
								}
							case 'Joined':
								if (_p11._1.ctor === 'Joined') {
									return state;
								} else {
									break _v5_5;
								}
							case 'Errored':
								if (_p11._1.ctor === 'Errored') {
									return state;
								} else {
									break _v5_5;
								}
							default:
								if (_p11._1.ctor === 'Disconnected') {
									return state;
								} else {
									break _v5_5;
								}
						}
					} else {
						break _v5_5;
					}
				} while(false);
				return A2(
					_elm_lang$core$Debug$log,
					A2(
						_elm_lang$core$Basics_ops['++'],
						'Channel \"',
						A2(_elm_lang$core$Basics_ops['++'], internalChannel.channel.topic, '\"')),
					state);
			}();
			return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel, state, internalChannel.channel);
		} else {
			return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel, state, internalChannel.channel);
		}
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$insertState = F4(
	function (endpoint, topic, state, dict) {
		var update = _elm_lang$core$Maybe$map(
			_saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateState(state));
		return A4(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$updateIn, endpoint, topic, update, dict);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$updatePayload = F2(
	function (payload, _p12) {
		var _p13 = _p12;
		return A2(
			_saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel,
			_p13.state,
			_elm_lang$core$Native_Utils.update(
				_p13.channel,
				{payload: payload}));
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateOn = F2(
	function (on, _p14) {
		var _p15 = _p14;
		return A2(
			_saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel,
			_p15.state,
			_elm_lang$core$Native_Utils.update(
				_p15.channel,
				{on: on}));
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Disconnected = {ctor: 'Disconnected'};
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Errored = {ctor: 'Errored'};
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Joined = {ctor: 'Joined'};
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Joining = {ctor: 'Joining'};
var _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Closed = {ctor: 'Closed'};

var _saschatimme$elm_phoenix$Phoenix_Socket$map = F2(
	function (func, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				onClose: A2(
					_elm_lang$core$Maybe$map,
					F2(
						function (x, y) {
							return function (_p0) {
								return x(
									y(_p0));
							};
						})(func),
					socket.onClose),
				onNormalClose: A2(_elm_lang$core$Maybe$map, func, socket.onNormalClose),
				onAbnormalClose: A2(_elm_lang$core$Maybe$map, func, socket.onAbnormalClose)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$defaultReconnectTimer = function (failedAttempts) {
	return (_elm_lang$core$Native_Utils.cmp(failedAttempts, 1) < 0) ? 0 : _elm_lang$core$Basics$toFloat(
		10 * Math.pow(2, failedAttempts));
};
var _saschatimme$elm_phoenix$Phoenix_Socket$onClose = F2(
	function (onClose_, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				onClose: _elm_lang$core$Maybe$Just(onClose_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$onNormalClose = F2(
	function (onNormalClose_, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				onNormalClose: _elm_lang$core$Maybe$Just(onNormalClose_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$onAbnormalClose = F2(
	function (onAbnormalClose_, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				onAbnormalClose: _elm_lang$core$Maybe$Just(onAbnormalClose_)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$withDebug = function (socket) {
	return _elm_lang$core$Native_Utils.update(
		socket,
		{debug: true});
};
var _saschatimme$elm_phoenix$Phoenix_Socket$reconnectTimer = F2(
	function (timerFunc, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{reconnectTimer: timerFunc});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$withoutHeartbeat = function (socket) {
	return _elm_lang$core$Native_Utils.update(
		socket,
		{withoutHeartbeat: true});
};
var _saschatimme$elm_phoenix$Phoenix_Socket$heartbeatIntervallSeconds = F2(
	function (intervall, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				heartbeatIntervall: _elm_lang$core$Basics$toFloat(intervall) * _elm_lang$core$Time$second
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$withParams = F2(
	function (params, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{params: params});
	});
var _saschatimme$elm_phoenix$Phoenix_Socket$init = function (endpoint) {
	return {
		endpoint: endpoint,
		params: {ctor: '[]'},
		heartbeatIntervall: 30 * _elm_lang$core$Time$second,
		withoutHeartbeat: false,
		reconnectTimer: _saschatimme$elm_phoenix$Phoenix_Socket$defaultReconnectTimer,
		debug: false,
		onClose: _elm_lang$core$Maybe$Nothing,
		onAbnormalClose: _elm_lang$core$Maybe$Nothing,
		onNormalClose: _elm_lang$core$Maybe$Nothing
	};
};
var _saschatimme$elm_phoenix$Phoenix_Socket$PhoenixSocket = F9(
	function (a, b, c, d, e, f, g, h, i) {
		return {endpoint: a, params: b, heartbeatIntervall: c, withoutHeartbeat: d, reconnectTimer: e, debug: f, onClose: g, onAbnormalClose: h, onNormalClose: i};
	});

var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$debugLogMessage = F2(
	function (_p0, msg) {
		var _p1 = _p0;
		return _p1.socket.debug ? A2(_elm_lang$core$Debug$log, 'Received', msg) : msg;
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$ref = function (_p2) {
	var _p3 = _p2;
	var _p4 = _p3.connection;
	if (_p4.ctor === 'Connected') {
		return _elm_lang$core$Maybe$Just(_p4._1);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$get = F2(
	function (endpoint, dict) {
		return A2(_elm_lang$core$Dict$get, endpoint, dict);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$getRef = F2(
	function (endpoint, dict) {
		return A2(
			_elm_lang$core$Maybe$andThen,
			_saschatimme$elm_phoenix$Phoenix_Internal_Socket$ref,
			A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$get, endpoint, dict));
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$close = function (_p5) {
	var _p6 = _p5;
	var _p7 = _p6.connection;
	switch (_p7.ctor) {
		case 'Opening':
			return _elm_lang$core$Process$kill(_p7._1);
		case 'Connected':
			return _elm_lang$websocket$WebSocket_LowLevel$close(_p7._0);
		default:
			return _elm_lang$core$Task$succeed(
				{ctor: '_Tuple0'});
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$after = function (backoff) {
	return (_elm_lang$core$Native_Utils.cmp(backoff, 1) < 0) ? _elm_lang$core$Task$succeed(
		{ctor: '_Tuple0'}) : _elm_lang$core$Process$sleep(backoff);
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$open = F2(
	function (_p8, settings) {
		var _p9 = _p8;
		var _p12 = _p9.socket;
		var query = A2(
			_elm_lang$core$String$join,
			'&',
			A2(
				_elm_lang$core$List$map,
				function (_p10) {
					var _p11 = _p10;
					return A2(
						_elm_lang$core$Basics_ops['++'],
						_p11._0,
						A2(_elm_lang$core$Basics_ops['++'], '=', _p11._1));
				},
				_p12.params));
		var url = A2(_elm_lang$core$String$contains, '?', _p12.endpoint) ? A2(
			_elm_lang$core$Basics_ops['++'],
			_p12.endpoint,
			A2(_elm_lang$core$Basics_ops['++'], '&', query)) : A2(
			_elm_lang$core$Basics_ops['++'],
			_p12.endpoint,
			A2(_elm_lang$core$Basics_ops['++'], '?', query));
		return A2(_elm_lang$websocket$WebSocket_LowLevel$open, url, settings);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$push = F2(
	function (message, _p13) {
		var _p14 = _p13;
		var _p19 = _p14.socket;
		var _p15 = _p14.connection;
		if (_p15.ctor === 'Connected') {
			var _p18 = _p15._1;
			var message_ = _p19.debug ? A2(
				_elm_lang$core$Debug$log,
				'Send',
				A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$ref, _p18, message)) : A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$ref, _p18, message);
			return A2(
				_elm_lang$core$Task$map,
				function (maybeBadSend) {
					var _p16 = maybeBadSend;
					if (_p16.ctor === 'Nothing') {
						return _elm_lang$core$Maybe$Just(_p18);
					} else {
						if (_p19.debug) {
							var _p17 = A2(_elm_lang$core$Debug$log, 'BadSend', _p16._0);
							return _elm_lang$core$Maybe$Nothing;
						} else {
							return _elm_lang$core$Maybe$Nothing;
						}
					}
				},
				A2(
					_elm_lang$websocket$WebSocket_LowLevel$send,
					_p15._0,
					_saschatimme$elm_phoenix$Phoenix_Internal_Message$encode(message_)));
		} else {
			return _elm_lang$core$Task$succeed(_elm_lang$core$Maybe$Nothing);
		}
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$isOpening = function (internalSocket) {
	var _p20 = internalSocket.connection;
	if (_p20.ctor === 'Opening') {
		return true;
	} else {
		return false;
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$InternalSocket = F2(
	function (a, b) {
		return {connection: a, socket: b};
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$Connected = F2(
	function (a, b) {
		return {ctor: 'Connected', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$connected = F2(
	function (ws, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				connection: A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$Connected, ws, 0)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$increaseRef = function (socket) {
	var _p21 = socket.connection;
	if (_p21.ctor === 'Connected') {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				connection: A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$Connected, _p21._0, _p21._1 + 1)
			});
	} else {
		return socket;
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$Opening = F2(
	function (a, b) {
		return {ctor: 'Opening', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$opening = F3(
	function (backoff, pid, socket) {
		return _elm_lang$core$Native_Utils.update(
			socket,
			{
				connection: A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$Opening, backoff, pid)
			});
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$resetBackoff = function (connection) {
	var _p22 = connection;
	if (_p22.ctor === 'Opening') {
		return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$Opening, 0, _p22._1);
	} else {
		return connection;
	}
};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$update = F2(
	function (nextSocket, _p23) {
		var _p24 = _p23;
		var _p25 = _p24.connection;
		var updatedConnection = (!_elm_lang$core$Native_Utils.eq(nextSocket.params, _p24.socket.params)) ? _saschatimme$elm_phoenix$Phoenix_Internal_Socket$resetBackoff(_p25) : _p25;
		return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$InternalSocket, updatedConnection, nextSocket);
	});
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$Closed = {ctor: 'Closed'};
var _saschatimme$elm_phoenix$Phoenix_Internal_Socket$internalSocket = function (socket) {
	return {connection: _saschatimme$elm_phoenix$Phoenix_Internal_Socket$Closed, socket: socket};
};

var _saschatimme$elm_phoenix$Phoenix$after = function (backoff) {
	return (_elm_lang$core$Native_Utils.cmp(backoff, 1) < 0) ? _elm_lang$core$Task$succeed(
		{ctor: '_Tuple0'}) : _elm_lang$core$Process$sleep(backoff);
};
var _saschatimme$elm_phoenix$Phoenix$heartbeatMessage = A2(_saschatimme$elm_phoenix$Phoenix_Internal_Message$init, 'phoenix', 'heartbeat');
var _saschatimme$elm_phoenix$Phoenix$handleChannelDisconnect = F3(
	function (router, endpoint, state) {
		var _p0 = A2(_elm_lang$core$Dict$get, endpoint, state.channels);
		if (_p0.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var _p8 = _p0._0;
			var updateChannel = F2(
				function (_p1, channel) {
					var _p2 = channel.state;
					if (_p2.ctor === 'Errored') {
						return channel;
					} else {
						return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateState, _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Disconnected, channel);
					}
				});
			var updatedEndpointChannels = A2(_elm_lang$core$Dict$map, updateChannel, _p8);
			var notifyApp = function (_p3) {
				var _p4 = _p3;
				var _p5 = _p4.state;
				if (_p5.ctor === 'Joined') {
					var _p6 = _p4.channel.onDisconnect;
					if (_p6.ctor === 'Nothing') {
						return _elm_lang$core$Task$succeed(
							{ctor: '_Tuple0'});
					} else {
						return A2(_elm_lang$core$Platform$sendToApp, router, _p6._0);
					}
				} else {
					return _elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'});
				}
			};
			var notify = A3(
				_elm_lang$core$Dict$foldl,
				F3(
					function (_p7, channel, task) {
						return A2(
							_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
							task,
							notifyApp(channel));
					}),
				_elm_lang$core$Task$succeed(
					{ctor: '_Tuple0'}),
				_p8);
			return A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
				notify,
				_elm_lang$core$Task$succeed(
					_elm_lang$core$Native_Utils.update(
						state,
						{
							channels: A3(_elm_lang$core$Dict$insert, endpoint, updatedEndpointChannels, state.channels)
						})));
		}
	});
var _saschatimme$elm_phoenix$Phoenix$getEventCb = F3(
	function (endpoint, message, channels) {
		var _p9 = A3(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$getIn, endpoint, message.topic, channels);
		if (_p9.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			return A2(_elm_lang$core$Dict$get, message.event, _p9._0.channel.on);
		}
	});
var _saschatimme$elm_phoenix$Phoenix$dispatchMessage = F4(
	function (router, endpoint, message, channels) {
		var _p10 = A3(_saschatimme$elm_phoenix$Phoenix$getEventCb, endpoint, message, channels);
		if (_p10.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(
				{ctor: '_Tuple0'});
		} else {
			return A2(
				_elm_lang$core$Platform$sendToApp,
				router,
				_p10._0(message.payload));
		}
	});
var _saschatimme$elm_phoenix$Phoenix$handleSelfcallback = F4(
	function (router, endpoint, message, selfCallbacks) {
		var _p11 = message.ref;
		if (_p11.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(selfCallbacks);
		} else {
			var _p13 = _p11._0;
			var _p12 = A2(_elm_lang$core$Dict$get, _p13, selfCallbacks);
			if (_p12.ctor === 'Nothing') {
				return _elm_lang$core$Task$succeed(selfCallbacks);
			} else {
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
					A2(
						_elm_lang$core$Platform$sendToSelf,
						router,
						_p12._0(message)),
					_elm_lang$core$Task$succeed(
						A2(_elm_lang$core$Dict$remove, _p13, selfCallbacks)));
			}
		}
	});
var _saschatimme$elm_phoenix$Phoenix$insertSelfCallback = F3(
	function (ref, maybeSelfCb, state) {
		var _p14 = maybeSelfCb;
		if (_p14.ctor === 'Nothing') {
			return state;
		} else {
			return _elm_lang$core$Native_Utils.update(
				state,
				{
					selfCallbacks: A3(_elm_lang$core$Dict$insert, ref, _p14._0, state.selfCallbacks)
				});
		}
	});
var _saschatimme$elm_phoenix$Phoenix$insertSocket = F3(
	function (endpoint, socket, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{
				sockets: A3(_elm_lang$core$Dict$insert, endpoint, socket, state.sockets)
			});
	});
var _saschatimme$elm_phoenix$Phoenix$pushSocket_ = F4(
	function (endpoint, message, maybeSelfCb, state) {
		var _p15 = A2(_elm_lang$core$Dict$get, endpoint, state.sockets);
		if (_p15.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var _p17 = _p15._0;
			return A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
				A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$push, message, _p17),
				function (maybeRef) {
					var _p16 = maybeRef;
					if (_p16.ctor === 'Nothing') {
						return _elm_lang$core$Task$succeed(state);
					} else {
						return _elm_lang$core$Task$succeed(
							A3(
								_saschatimme$elm_phoenix$Phoenix$insertSelfCallback,
								_p16._0,
								maybeSelfCb,
								A3(
									_saschatimme$elm_phoenix$Phoenix$insertSocket,
									endpoint,
									_saschatimme$elm_phoenix$Phoenix_Internal_Socket$increaseRef(_p17),
									state)));
					}
				});
		}
	});
var _saschatimme$elm_phoenix$Phoenix$pushSocket = F4(
	function (endpoint, message, selfCb, state) {
		var queuedState = _elm_lang$core$Task$succeed(
			_elm_lang$core$Native_Utils.update(
				state,
				{
					channelQueues: A4(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$updateIn,
						endpoint,
						message.topic,
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$add(
							{ctor: '_Tuple2', _0: message, _1: selfCb}),
						state.channelQueues)
				}));
		var afterSocketPush = F2(
			function (socket, maybeRef) {
				var _p18 = maybeRef;
				if (_p18.ctor === 'Nothing') {
					return queuedState;
				} else {
					return _elm_lang$core$Task$succeed(
						A3(
							_saschatimme$elm_phoenix$Phoenix$insertSelfCallback,
							_p18._0,
							selfCb,
							A3(
								_saschatimme$elm_phoenix$Phoenix$insertSocket,
								endpoint,
								_saschatimme$elm_phoenix$Phoenix_Internal_Socket$increaseRef(socket),
								state)));
				}
			});
		var _p19 = A2(_elm_lang$core$Dict$get, endpoint, state.sockets);
		if (_p19.ctor === 'Nothing') {
			return queuedState;
		} else {
			var _p24 = _p19._0;
			var _p20 = A3(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$get, endpoint, message.topic, state.channels);
			if (_p20.ctor === 'Nothing') {
				var _p21 = A2(_elm_lang$core$Debug$log, 'Queued message (no channel exists)', message);
				return queuedState;
			} else {
				var _p22 = _p20._0.state;
				if (_p22.ctor === 'Joined') {
					return A2(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
						A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$push, message, _p24),
						afterSocketPush(_p24));
				} else {
					var _p23 = A2(_elm_lang$core$Debug$log, 'Queued message (channel not joined)', message);
					return queuedState;
				}
			}
		}
	});
var _saschatimme$elm_phoenix$Phoenix$processQueue = F3(
	function (endpoint, messages, state) {
		var _p25 = messages;
		if (_p25.ctor === '[]') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			return A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
				A4(_saschatimme$elm_phoenix$Phoenix$pushSocket, endpoint, _p25._0._0, _p25._0._1, state),
				A2(_saschatimme$elm_phoenix$Phoenix$processQueue, endpoint, _p25._1));
		}
	});
var _saschatimme$elm_phoenix$Phoenix$removeChannelQueue = F3(
	function (endpoint, topic, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{
				channelQueues: A3(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$removeIn, endpoint, topic, state.channelQueues)
			});
	});
var _saschatimme$elm_phoenix$Phoenix$updateSelfCallbacks = F2(
	function (selfCallbacks, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{selfCallbacks: selfCallbacks});
	});
var _saschatimme$elm_phoenix$Phoenix$updateChannels = F2(
	function (channels, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{channels: channels});
	});
var _saschatimme$elm_phoenix$Phoenix$updateSocket = F3(
	function (endpoint, socket, state) {
		return _elm_lang$core$Native_Utils.update(
			state,
			{
				sockets: A3(_elm_lang$core$Dict$insert, endpoint, socket, state.sockets)
			});
	});
var _saschatimme$elm_phoenix$Phoenix$buildChannelsDict = F2(
	function (subs, dict) {
		var _p26 = subs;
		if (_p26.ctor === '[]') {
			return dict;
		} else {
			var internalChan = function (chan) {
				return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$InternalChannel, _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Closed, chan);
			};
			var build = F2(
				function (chan, dict_) {
					return A2(
						_saschatimme$elm_phoenix$Phoenix$buildChannelsDict,
						_p26._1,
						A4(
							_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$insertIn,
							_p26._0._0.endpoint,
							chan.topic,
							internalChan(chan),
							dict_));
				});
			return A3(_elm_lang$core$List$foldl, build, dict, _p26._0._1);
		}
	});
var _saschatimme$elm_phoenix$Phoenix$buildSocketsDict = function (subs) {
	var insert = F2(
		function (sub, dict) {
			var _p27 = sub;
			var _p28 = _p27._0;
			return A3(_elm_lang$core$Dict$insert, _p28.endpoint, _p28, dict);
		});
	return A3(_elm_lang$core$List$foldl, insert, _elm_lang$core$Dict$empty, subs);
};
var _saschatimme$elm_phoenix$Phoenix$subscription = _elm_lang$core$Native_Platform.leaf('Phoenix');
var _saschatimme$elm_phoenix$Phoenix$command = _elm_lang$core$Native_Platform.leaf('Phoenix');
var _saschatimme$elm_phoenix$Phoenix$State = F4(
	function (a, b, c, d) {
		return {sockets: a, channels: b, selfCallbacks: c, channelQueues: d};
	});
var _saschatimme$elm_phoenix$Phoenix$init = _elm_lang$core$Task$succeed(
	A4(_saschatimme$elm_phoenix$Phoenix$State, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty));
var _saschatimme$elm_phoenix$Phoenix$Connect = F2(
	function (a, b) {
		return {ctor: 'Connect', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$connect = F2(
	function (socket, channels) {
		return _saschatimme$elm_phoenix$Phoenix$subscription(
			A2(_saschatimme$elm_phoenix$Phoenix$Connect, socket, channels));
	});
var _saschatimme$elm_phoenix$Phoenix$subMap = F2(
	function (func, sub) {
		var _p29 = sub;
		return A2(
			_saschatimme$elm_phoenix$Phoenix$Connect,
			A2(_saschatimme$elm_phoenix$Phoenix_Socket$map, func, _p29._0),
			A2(
				_elm_lang$core$List$map,
				_saschatimme$elm_phoenix$Phoenix_Channel$map(func),
				_p29._1));
	});
var _saschatimme$elm_phoenix$Phoenix$Send = F2(
	function (a, b) {
		return {ctor: 'Send', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$push = F2(
	function (endpoint, push_) {
		return _saschatimme$elm_phoenix$Phoenix$command(
			A2(_saschatimme$elm_phoenix$Phoenix$Send, endpoint, push_));
	});
var _saschatimme$elm_phoenix$Phoenix$cmdMap = F2(
	function (func, cmd) {
		var _p30 = cmd;
		return A2(
			_saschatimme$elm_phoenix$Phoenix$Send,
			_p30._0,
			A2(_saschatimme$elm_phoenix$Phoenix_Push$map, func, _p30._1));
	});
var _saschatimme$elm_phoenix$Phoenix$PushResponse = F2(
	function (a, b) {
		return {ctor: 'PushResponse', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$sendPushsHelp = F2(
	function (cmds, state) {
		var _p31 = cmds;
		if (_p31.ctor === '[]') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var _p32 = _p31._0._1;
			var message = _saschatimme$elm_phoenix$Phoenix_Internal_Message$fromPush(_p32);
			return A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
				A4(
					_saschatimme$elm_phoenix$Phoenix$pushSocket,
					_p31._0._0,
					message,
					_elm_lang$core$Maybe$Just(
						_saschatimme$elm_phoenix$Phoenix$PushResponse(_p32)),
					state),
				_saschatimme$elm_phoenix$Phoenix$sendPushsHelp(_p31._1));
		}
	});
var _saschatimme$elm_phoenix$Phoenix$SendHeartbeat = function (a) {
	return {ctor: 'SendHeartbeat', _0: a};
};
var _saschatimme$elm_phoenix$Phoenix$heartbeat = F3(
	function (router, endpoint, state) {
		var _p33 = A2(_elm_lang$core$Dict$get, endpoint, state.sockets);
		if (_p33.ctor === 'Just') {
			var _p34 = _p33._0.socket;
			return _p34.withoutHeartbeat ? _elm_lang$core$Task$succeed(state) : A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
				_elm_lang$core$Process$spawn(
					A2(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
						_elm_lang$core$Process$sleep(_p34.heartbeatIntervall),
						A2(
							_elm_lang$core$Platform$sendToSelf,
							router,
							_saschatimme$elm_phoenix$Phoenix$SendHeartbeat(endpoint)))),
				A4(_saschatimme$elm_phoenix$Phoenix$pushSocket_, endpoint, _saschatimme$elm_phoenix$Phoenix$heartbeatMessage, _elm_lang$core$Maybe$Nothing, state));
		} else {
			return _elm_lang$core$Task$succeed(state);
		}
	});
var _saschatimme$elm_phoenix$Phoenix$GoodJoin = F2(
	function (a, b) {
		return {ctor: 'GoodJoin', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$handleChannelJoinReply = F6(
	function (router, endpoint, topic, message, prevState, channels) {
		var newChannels = function (state) {
			return _elm_lang$core$Task$succeed(
				A4(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$insertState, endpoint, topic, state, channels));
		};
		var handlePayload = F2(
			function (_p35, payload) {
				var _p36 = _p35;
				var _p43 = _p36.channel;
				var _p37 = payload;
				if (_p37.ctor === 'Err') {
					var _p38 = _p43.onJoinError;
					if (_p38.ctor === 'Nothing') {
						return newChannels(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$Errored);
					} else {
						return A2(
							_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
							A2(
								_elm_lang$core$Platform$sendToApp,
								router,
								_p38._0(_p37._0)),
							newChannels(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$Errored));
					}
				} else {
					var _p42 = _p37._0;
					var join = A2(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
						A2(
							_elm_lang$core$Platform$sendToSelf,
							router,
							A2(_saschatimme$elm_phoenix$Phoenix$GoodJoin, endpoint, topic)),
						newChannels(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$Joined));
					var _p39 = prevState;
					if (_p39.ctor === 'Disconnected') {
						var _p40 = _p43.onRejoin;
						if (_p40.ctor === 'Nothing') {
							return join;
						} else {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									_p40._0(_p42)),
								join);
						}
					} else {
						var _p41 = _p43.onJoin;
						if (_p41.ctor === 'Nothing') {
							return join;
						} else {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									_p41._0(_p42)),
								join);
						}
					}
				}
			});
		var maybePayload = _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$decodeReplyPayload(message.payload);
		var maybeChannel = A3(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$get, endpoint, topic, channels);
		return A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Task$succeed(channels),
			A3(_elm_lang$core$Maybe$map2, handlePayload, maybeChannel, maybePayload));
	});
var _saschatimme$elm_phoenix$Phoenix$ChannelJoinReply = F4(
	function (a, b, c, d) {
		return {ctor: 'ChannelJoinReply', _0: a, _1: b, _2: c, _3: d};
	});
var _saschatimme$elm_phoenix$Phoenix$sendJoinHelper = F3(
	function (endpoint, channels, state) {
		var _p44 = channels;
		if (_p44.ctor === '[]') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			var _p45 = _p44._0;
			var newChannel = A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateState, _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Joining, _p45);
			var newChannels = A4(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$insertIn, endpoint, _p45.channel.topic, newChannel, state.channels);
			var message = _saschatimme$elm_phoenix$Phoenix_Internal_Channel$joinMessage(_p45);
			var selfCb = A3(_saschatimme$elm_phoenix$Phoenix$ChannelJoinReply, endpoint, _p45.channel.topic, _p45.state);
			return A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
				A4(
					_saschatimme$elm_phoenix$Phoenix$pushSocket_,
					endpoint,
					message,
					_elm_lang$core$Maybe$Just(selfCb),
					A2(_saschatimme$elm_phoenix$Phoenix$updateChannels, newChannels, state)),
				function (newState) {
					return A3(_saschatimme$elm_phoenix$Phoenix$sendJoinHelper, endpoint, _p44._1, newState);
				});
		}
	});
var _saschatimme$elm_phoenix$Phoenix$handlePhoenixMessage = F4(
	function (router, endpoint, message, state) {
		var _p46 = message.event;
		switch (_p46) {
			case 'phx_error':
				var _p47 = A3(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$getIn, endpoint, message.topic, state.channels);
				if (_p47.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p49 = _p47._0;
					var sendToApp = function () {
						var _p48 = _p49.channel.onError;
						if (_p48.ctor === 'Nothing') {
							return _elm_lang$core$Task$succeed(
								{ctor: '_Tuple0'});
						} else {
							return A2(_elm_lang$core$Platform$sendToApp, router, _p48._0);
						}
					}();
					var newChannel = A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateState, _saschatimme$elm_phoenix$Phoenix_Internal_Channel$Errored, _p49);
					return A2(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
						sendToApp,
						A3(
							_saschatimme$elm_phoenix$Phoenix$sendJoinHelper,
							endpoint,
							{
								ctor: '::',
								_0: newChannel,
								_1: {ctor: '[]'}
							},
							state));
				}
			case 'phx_close':
				return _elm_lang$core$Task$succeed(state);
			default:
				return _elm_lang$core$Task$succeed(state);
		}
	});
var _saschatimme$elm_phoenix$Phoenix$rejoinAllChannels = F2(
	function (endpoint, state) {
		var _p50 = A2(_elm_lang$core$Dict$get, endpoint, state.channels);
		if (_p50.ctor === 'Nothing') {
			return _elm_lang$core$Task$succeed(state);
		} else {
			return A3(
				_saschatimme$elm_phoenix$Phoenix$sendJoinHelper,
				endpoint,
				_elm_lang$core$Dict$values(_p50._0),
				state);
		}
	});
var _saschatimme$elm_phoenix$Phoenix$ChannelLeaveReply = F3(
	function (a, b, c) {
		return {ctor: 'ChannelLeaveReply', _0: a, _1: b, _2: c};
	});
var _saschatimme$elm_phoenix$Phoenix$LeaveChannel = F2(
	function (a, b) {
		return {ctor: 'LeaveChannel', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$sendLeaveChannel = F3(
	function (router, endpoint, internalChannel) {
		var _p51 = internalChannel.state;
		if (_p51.ctor === 'Joined') {
			return A2(
				_elm_lang$core$Platform$sendToSelf,
				router,
				A2(_saschatimme$elm_phoenix$Phoenix$LeaveChannel, endpoint, internalChannel));
		} else {
			return _elm_lang$core$Task$succeed(
				{ctor: '_Tuple0'});
		}
	});
var _saschatimme$elm_phoenix$Phoenix$JoinChannel = F2(
	function (a, b) {
		return {ctor: 'JoinChannel', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$sendJoinChannel = F3(
	function (router, endpoint, internalChannel) {
		return A2(
			_elm_lang$core$Platform$sendToSelf,
			router,
			A2(_saschatimme$elm_phoenix$Phoenix$JoinChannel, endpoint, internalChannel));
	});
var _saschatimme$elm_phoenix$Phoenix$handleEndpointChannelsUpdate = F4(
	function (router, endpoint, definedChannels, stateChannels) {
		var rightStep = F3(
			function (topic, state, getNewChannels) {
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
					A3(_saschatimme$elm_phoenix$Phoenix$sendLeaveChannel, router, endpoint, state),
					getNewChannels);
			});
		var bothStep = F4(
			function (topic, defined, state, getNewChannels) {
				var channel = A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Channel$updateOn,
					defined.channel.on,
					A2(_saschatimme$elm_phoenix$Phoenix_Internal_Channel$updatePayload, defined.channel.payload, state));
				return A2(
					_elm_lang$core$Task$map,
					A2(_elm_lang$core$Dict$insert, topic, channel),
					getNewChannels);
			});
		var leftStep = F3(
			function (topic, defined, getNewChannels) {
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
					A3(_saschatimme$elm_phoenix$Phoenix$sendJoinChannel, router, endpoint, defined),
					A2(
						_elm_lang$core$Task$map,
						A2(_elm_lang$core$Dict$insert, topic, defined),
						getNewChannels));
			});
		return A6(
			_elm_lang$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			definedChannels,
			stateChannels,
			_elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty));
	});
var _saschatimme$elm_phoenix$Phoenix$handleChannelsUpdate = F3(
	function (router, definedChannels, internalChannels) {
		var rightStep = F3(
			function (endpoint, stateEndpointChannels, getNewChannels) {
				var sendLeave = A3(
					_elm_lang$core$List$foldl,
					F2(
						function (channel, task) {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								task,
								A3(_saschatimme$elm_phoenix$Phoenix$sendLeaveChannel, router, endpoint, channel));
						}),
					_elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'}),
					_elm_lang$core$Dict$values(stateEndpointChannels));
				return A2(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'], sendLeave, getNewChannels);
			});
		var bothStep = F4(
			function (endpoint, definedEndpointChannels, stateEndpointChannels, getNewChannels) {
				var getEndpointChannels = A4(_saschatimme$elm_phoenix$Phoenix$handleEndpointChannelsUpdate, router, endpoint, definedEndpointChannels, stateEndpointChannels);
				return A3(
					_elm_lang$core$Task$map2,
					F2(
						function (endpointChannels, newChannels) {
							return A3(_elm_lang$core$Dict$insert, endpoint, endpointChannels, newChannels);
						}),
					getEndpointChannels,
					getNewChannels);
			});
		var leftStep = F3(
			function (endpoint, definedEndpointChannels, getNewChannels) {
				var insert = function (newChannels) {
					return _elm_lang$core$Task$succeed(
						A3(_elm_lang$core$Dict$insert, endpoint, definedEndpointChannels, newChannels));
				};
				var sendJoin = A3(
					_elm_lang$core$List$foldl,
					F2(
						function (channel, task) {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								task,
								A3(_saschatimme$elm_phoenix$Phoenix$sendJoinChannel, router, endpoint, channel));
						}),
					_elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'}),
					_elm_lang$core$Dict$values(definedEndpointChannels));
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
					A2(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'], sendJoin, getNewChannels),
					insert);
			});
		return A6(
			_elm_lang$core$Dict$merge,
			leftStep,
			bothStep,
			rightStep,
			definedChannels,
			internalChannels,
			_elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty));
	});
var _saschatimme$elm_phoenix$Phoenix$Register = {ctor: 'Register'};
var _saschatimme$elm_phoenix$Phoenix$BadOpen = F2(
	function (a, b) {
		return {ctor: 'BadOpen', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$GoodOpen = F2(
	function (a, b) {
		return {ctor: 'GoodOpen', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$Die = F2(
	function (a, b) {
		return {ctor: 'Die', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$Receive = F2(
	function (a, b) {
		return {ctor: 'Receive', _0: a, _1: b};
	});
var _saschatimme$elm_phoenix$Phoenix$open = F2(
	function (socket, router) {
		var onMessage = F2(
			function (_p52, msg) {
				var _p53 = _saschatimme$elm_phoenix$Phoenix_Internal_Message$decode(msg);
				if (_p53.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform$sendToSelf,
						router,
						A2(
							_saschatimme$elm_phoenix$Phoenix$Receive,
							socket.socket.endpoint,
							A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$debugLogMessage, socket, _p53._0)));
				} else {
					return _elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'});
				}
			});
		return A2(
			_saschatimme$elm_phoenix$Phoenix_Internal_Socket$open,
			socket,
			{
				onMessage: onMessage,
				onClose: function (details) {
					return A2(
						_elm_lang$core$Platform$sendToSelf,
						router,
						A2(_saschatimme$elm_phoenix$Phoenix$Die, socket.socket.endpoint, details));
				}
			});
	});
var _saschatimme$elm_phoenix$Phoenix$attemptOpen = F3(
	function (router, backoff, _p54) {
		var _p55 = _p54;
		var _p56 = _p55.socket;
		var badOpen = function (details) {
			return A2(
				_elm_lang$core$Platform$sendToSelf,
				router,
				A2(_saschatimme$elm_phoenix$Phoenix$BadOpen, _p56.endpoint, details));
		};
		var goodOpen = function (ws) {
			return A2(
				_elm_lang$core$Platform$sendToSelf,
				router,
				A2(_saschatimme$elm_phoenix$Phoenix$GoodOpen, _p56.endpoint, ws));
		};
		var actuallyAttemptOpen = A2(
			_elm_lang$core$Task$onError,
			badOpen,
			A2(
				_elm_lang$core$Task$andThen,
				goodOpen,
				A2(_saschatimme$elm_phoenix$Phoenix$open, _p55, router)));
		return _elm_lang$core$Process$spawn(
			A2(
				_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
				_saschatimme$elm_phoenix$Phoenix$after(backoff),
				actuallyAttemptOpen));
	});
var _saschatimme$elm_phoenix$Phoenix$handleSocketsUpdate = F3(
	function (router, definedSockets, stateSockets) {
		var removedSocketsStep = F3(
			function (endpoint, stateSocket, taskChain) {
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
					_saschatimme$elm_phoenix$Phoenix_Internal_Socket$close(stateSocket),
					taskChain);
			});
		var retainedSocketsStep = F4(
			function (endpoint, definedSocket, stateSocket, taskChain) {
				return A2(
					_elm_lang$core$Task$map,
					A2(
						_elm_lang$core$Dict$insert,
						endpoint,
						A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$update, definedSocket, stateSocket)),
					taskChain);
			});
		var addedSocketsStep = F3(
			function (endpoint, definedSocket, taskChain) {
				var socket = _saschatimme$elm_phoenix$Phoenix_Internal_Socket$internalSocket(definedSocket);
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
					taskChain,
					function (addedSockets) {
						return A2(
							_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
							A3(_saschatimme$elm_phoenix$Phoenix$attemptOpen, router, 0, socket),
							function (pid) {
								return _elm_lang$core$Task$succeed(
									A3(
										_elm_lang$core$Dict$insert,
										endpoint,
										A3(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$opening, 0, pid, socket),
										addedSockets));
							});
					});
			});
		return A6(
			_elm_lang$core$Dict$merge,
			addedSocketsStep,
			retainedSocketsStep,
			removedSocketsStep,
			definedSockets,
			stateSockets,
			_elm_lang$core$Task$succeed(_elm_lang$core$Dict$empty));
	});
var _saschatimme$elm_phoenix$Phoenix$onEffects = F4(
	function (router, cmds, subs, state) {
		var definedChannels = A2(_saschatimme$elm_phoenix$Phoenix$buildChannelsDict, subs, _elm_lang$core$Dict$empty);
		var definedSockets = _saschatimme$elm_phoenix$Phoenix$buildSocketsDict(subs);
		var updateState = function (newState) {
			var getNewSockets = A3(_saschatimme$elm_phoenix$Phoenix$handleSocketsUpdate, router, definedSockets, newState.sockets);
			var getNewChannels = A3(_saschatimme$elm_phoenix$Phoenix$handleChannelsUpdate, router, definedChannels, newState.channels);
			return A3(
				_elm_lang$core$Task$map2,
				F2(
					function (newSockets, newChannels) {
						return _elm_lang$core$Native_Utils.update(
							newState,
							{sockets: newSockets, channels: newChannels});
					}),
				getNewSockets,
				getNewChannels);
		};
		return A2(
			_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
			A2(_saschatimme$elm_phoenix$Phoenix$sendPushsHelp, cmds, state),
			function (newState) {
				return updateState(newState);
			});
	});
var _saschatimme$elm_phoenix$Phoenix$onSelfMsg = F3(
	function (router, selfMsg, state) {
		var _p57 = selfMsg;
		switch (_p57.ctor) {
			case 'GoodOpen':
				var _p61 = _p57._0;
				var _p58 = A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$get, _p61, state.sockets);
				if (_p58.ctor === 'Just') {
					var _p60 = _p58._0;
					var state_ = A3(
						_saschatimme$elm_phoenix$Phoenix$insertSocket,
						_p61,
						A2(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$connected, _p57._1, _p60),
						state);
					var _p59 = _p60.socket.debug ? A2(_elm_lang$core$Debug$log, 'WebSocket connected with ', _p61) : _p61;
					return A2(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
						A3(_saschatimme$elm_phoenix$Phoenix$heartbeat, router, _p61, state_),
						function (newState) {
							return A2(_saschatimme$elm_phoenix$Phoenix$rejoinAllChannels, _p61, newState);
						});
				} else {
					return _elm_lang$core$Task$succeed(state);
				}
			case 'BadOpen':
				var _p67 = _p57._0;
				var _p66 = _p57._1;
				var _p62 = A2(_elm_lang$core$Dict$get, _p67, state.sockets);
				if (_p62.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p65 = _p62._0;
					var backoffIteration = function () {
						var _p63 = _p65.connection;
						if (_p63.ctor === 'Opening') {
							return _p63._0 + 1;
						} else {
							return 0;
						}
					}();
					var backoff = _p65.socket.reconnectTimer(backoffIteration);
					var newState = function (pid) {
						return A3(
							_saschatimme$elm_phoenix$Phoenix$updateSocket,
							_p67,
							A3(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$opening, backoffIteration, pid, _p65),
							state);
					};
					var _p64 = _p65.socket.debug ? A2(
						_elm_lang$core$Debug$log,
						A2(_elm_lang$core$Basics_ops['++'], 'WebSocket couldn_t connect with ', _p67),
						_p66) : _p66;
					return A2(
						_elm_lang$core$Task$map,
						newState,
						A3(_saschatimme$elm_phoenix$Phoenix$attemptOpen, router, backoff, _p65));
				}
			case 'Die':
				var _p73 = _p57._0;
				var _p72 = _p57._1;
				var _p68 = A2(_elm_lang$core$Dict$get, _p73, state.sockets);
				if (_p68.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p71 = _p68._0.socket;
					var _p70 = _p68._0;
					var notifyOnAbnormalClose = (_saschatimme$elm_phoenix$Phoenix_Internal_Socket$isOpening(_p70) || (!_elm_lang$core$Native_Utils.eq(_p72.code, 1006))) ? _elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'}) : A2(
						_elm_lang$core$Maybe$withDefault,
						_elm_lang$core$Task$succeed(
							{ctor: '_Tuple0'}),
						A2(
							_elm_lang$core$Maybe$map,
							_elm_lang$core$Platform$sendToApp(router),
							_p71.onAbnormalClose));
					var notifyOnNormalClose = (_saschatimme$elm_phoenix$Phoenix_Internal_Socket$isOpening(_p70) || (!_elm_lang$core$Native_Utils.eq(_p72.code, 1000))) ? _elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'}) : A2(
						_elm_lang$core$Maybe$withDefault,
						_elm_lang$core$Task$succeed(
							{ctor: '_Tuple0'}),
						A2(
							_elm_lang$core$Maybe$map,
							_elm_lang$core$Platform$sendToApp(router),
							_p71.onNormalClose));
					var notifyOnClose = _saschatimme$elm_phoenix$Phoenix_Internal_Socket$isOpening(_p70) ? _elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'}) : A2(
						_elm_lang$core$Maybe$withDefault,
						_elm_lang$core$Task$succeed(
							{ctor: '_Tuple0'}),
						A2(
							_elm_lang$core$Maybe$map,
							function (onClose) {
								return A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									onClose(_p72));
							},
							_p71.onClose));
					var getNewState = A3(_saschatimme$elm_phoenix$Phoenix$handleChannelDisconnect, router, _p73, state);
					var backoffIteration = function () {
						var _p69 = _p68._0.connection;
						if (_p69.ctor === 'Opening') {
							return _p69._0 + 1;
						} else {
							return 0;
						}
					}();
					var backoff = _p71.reconnectTimer(backoffIteration);
					var finalNewState = function (pid) {
						return A2(
							_elm_lang$core$Task$map,
							A2(
								_saschatimme$elm_phoenix$Phoenix$updateSocket,
								_p73,
								A3(_saschatimme$elm_phoenix$Phoenix_Internal_Socket$opening, backoffIteration, pid, _p70)),
							getNewState);
					};
					return A2(
						_elm_lang$core$Task$andThen,
						finalNewState,
						A2(
							_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
							A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'], notifyOnClose, notifyOnNormalClose),
								notifyOnAbnormalClose),
							A3(_saschatimme$elm_phoenix$Phoenix$attemptOpen, router, backoff, _p70)));
				}
			case 'Receive':
				var _p75 = _p57._1;
				var _p74 = _p57._0;
				return A2(
					_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['<&>'],
					A2(
						_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
						A4(_saschatimme$elm_phoenix$Phoenix$dispatchMessage, router, _p74, _p75, state.channels),
						A2(
							_elm_lang$core$Task$map,
							function (selfCbs) {
								return A2(_saschatimme$elm_phoenix$Phoenix$updateSelfCallbacks, selfCbs, state);
							},
							A4(_saschatimme$elm_phoenix$Phoenix$handleSelfcallback, router, _p74, _p75, state.selfCallbacks))),
					A3(_saschatimme$elm_phoenix$Phoenix$handlePhoenixMessage, router, _p74, _p75));
			case 'ChannelJoinReply':
				return A2(
					_elm_lang$core$Task$map,
					function (newChannels) {
						return A2(_saschatimme$elm_phoenix$Phoenix$updateChannels, newChannels, state);
					},
					A6(_saschatimme$elm_phoenix$Phoenix$handleChannelJoinReply, router, _p57._0, _p57._1, _p57._3, _p57._2, state.channels));
			case 'JoinChannel':
				var _p79 = _p57._1;
				var _p78 = _p57._0;
				var _p76 = A2(_elm_lang$core$Dict$get, _p78, state.sockets);
				if (_p76.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p77 = _p76._0.connection;
					if (_p77.ctor === 'Connected') {
						return A4(
							_saschatimme$elm_phoenix$Phoenix$pushSocket_,
							_p78,
							_saschatimme$elm_phoenix$Phoenix_Internal_Channel$joinMessage(_p79),
							_elm_lang$core$Maybe$Just(
								A3(_saschatimme$elm_phoenix$Phoenix$ChannelJoinReply, _p78, _p79.channel.topic, _p79.state)),
							state);
					} else {
						return _elm_lang$core$Task$succeed(state);
					}
				}
			case 'LeaveChannel':
				var _p83 = _p57._1;
				var _p82 = _p57._0;
				var _p80 = A2(_elm_lang$core$Dict$get, _p82, state.sockets);
				if (_p80.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p81 = _p83.state;
					if (_p81.ctor === 'Joined') {
						return A4(
							_saschatimme$elm_phoenix$Phoenix$pushSocket_,
							_p82,
							_saschatimme$elm_phoenix$Phoenix_Internal_Channel$leaveMessage(_p83),
							_elm_lang$core$Maybe$Just(
								A2(_saschatimme$elm_phoenix$Phoenix$ChannelLeaveReply, _p82, _p83)),
							state);
					} else {
						return _elm_lang$core$Task$succeed(state);
					}
				}
			case 'ChannelLeaveReply':
				var _p88 = _p57._1.channel;
				var _p84 = _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$decodeReplyPayload(_p57._2.payload);
				if (_p84.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p85 = _p84._0;
					if (_p85.ctor === 'Err') {
						var _p86 = _p88.onLeaveError;
						if (_p86.ctor === 'Nothing') {
							return _elm_lang$core$Task$succeed(state);
						} else {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									_p86._0(_p85._0)),
								_elm_lang$core$Task$succeed(state));
						}
					} else {
						var _p87 = _p88.onLeave;
						if (_p87.ctor === 'Nothing') {
							return _elm_lang$core$Task$succeed(state);
						} else {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									_p87._0(_p85._0)),
								_elm_lang$core$Task$succeed(state));
						}
					}
				}
			case 'SendHeartbeat':
				return A3(_saschatimme$elm_phoenix$Phoenix$heartbeat, router, _p57._0, state);
			case 'GoodJoin':
				var _p91 = _p57._1;
				var _p90 = _p57._0;
				var _p89 = A3(_saschatimme$elm_phoenix$Phoenix_Internal_Helpers$getIn, _p90, _p91, state.channelQueues);
				if (_p89.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					return A2(
						_elm_lang$core$Task$map,
						A2(_saschatimme$elm_phoenix$Phoenix$removeChannelQueue, _p90, _p91),
						A3(_saschatimme$elm_phoenix$Phoenix$processQueue, _p90, _p89._0, state));
				}
			case 'PushResponse':
				var _p96 = _p57._0;
				var _p92 = _saschatimme$elm_phoenix$Phoenix_Internal_Helpers$decodeReplyPayload(_p57._1.payload);
				if (_p92.ctor === 'Nothing') {
					return _elm_lang$core$Task$succeed(state);
				} else {
					var _p93 = _p92._0;
					if (_p93.ctor === 'Err') {
						var _p94 = _p96.onError;
						if (_p94.ctor === 'Nothing') {
							return _elm_lang$core$Task$succeed(state);
						} else {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									_p94._0(_p93._0)),
								_elm_lang$core$Task$succeed(state));
						}
					} else {
						var _p95 = _p96.onOk;
						if (_p95.ctor === 'Nothing') {
							return _elm_lang$core$Task$succeed(state);
						} else {
							return A2(
								_saschatimme$elm_phoenix$Phoenix_Internal_Helpers_ops['&>'],
								A2(
									_elm_lang$core$Platform$sendToApp,
									router,
									_p95._0(_p93._0)),
								_elm_lang$core$Task$succeed(state));
						}
					}
				}
			default:
				return _elm_lang$core$Task$succeed(state);
		}
	});
_elm_lang$core$Native_Platform.effectManagers['Phoenix'] = {pkg: 'saschatimme/elm-phoenix', init: _saschatimme$elm_phoenix$Phoenix$init, onEffects: _saschatimme$elm_phoenix$Phoenix$onEffects, onSelfMsg: _saschatimme$elm_phoenix$Phoenix$onSelfMsg, tag: 'fx', cmdMap: _saschatimme$elm_phoenix$Phoenix$cmdMap, subMap: _saschatimme$elm_phoenix$Phoenix$subMap};

var _user$project$App_Types$Amishi = F4(
	function (a, b, c, d) {
		return {id: a, email: b, avatarUrl: c, displayName: d};
	});
var _user$project$App_Types$decodeAmishi = A5(
	_elm_lang$core$Json_Decode$map4,
	_user$project$App_Types$Amishi,
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'email', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'avatar_url', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'display_name', _elm_lang$core$Json_Decode$string));
var _user$project$App_Types$toAmishi = function (session) {
	return A4(_user$project$App_Types$Amishi, session.id, session.email, session.avatarUrl, session.displayName);
};
var _user$project$App_Types$Session = F6(
	function (a, b, c, d, e, f) {
		return {token: a, websocketUrl: b, id: c, email: d, avatarUrl: e, displayName: f};
	});
var _user$project$App_Types$decodeSession = A7(
	_elm_lang$core$Json_Decode$map6,
	_user$project$App_Types$Session,
	A2(_elm_lang$core$Json_Decode$field, 'token', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'websocket_url', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'email', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'avatar_url', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'display_name', _elm_lang$core$Json_Decode$string));
var _user$project$App_Types$Coto = F5(
	function (a, b, c, d, e) {
		return {id: a, content: b, postedIn: c, asCotonoma: d, cotonomaKey: e};
	});
var _user$project$App_Types$Cotonoma = F5(
	function (a, b, c, d, e) {
		return {id: a, key: b, name: c, cotoId: d, owner: e};
	});
var _user$project$App_Types$decodeCotonoma = A6(
	_elm_lang$core$Json_Decode$map5,
	_user$project$App_Types$Cotonoma,
	A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int),
	A2(_elm_lang$core$Json_Decode$field, 'key', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'name', _elm_lang$core$Json_Decode$string),
	A2(_elm_lang$core$Json_Decode$field, 'coto_id', _elm_lang$core$Json_Decode$int),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode$field, 'owner', _user$project$App_Types$decodeAmishi)));
var _user$project$App_Types$NotFoundRoute = {ctor: 'NotFoundRoute'};
var _user$project$App_Types$CotonomaRoute = function (a) {
	return {ctor: 'CotonomaRoute', _0: a};
};
var _user$project$App_Types$HomeRoute = {ctor: 'HomeRoute'};

var _user$project$Components_ConfirmModal_Messages$Confirm = {ctor: 'Confirm'};
var _user$project$Components_ConfirmModal_Messages$Close = {ctor: 'Close'};

var _user$project$Utils$emailRegex = _elm_lang$core$Regex$caseInsensitive(
	_elm_lang$core$Regex$regex('^[a-zA-Z0-9.!#$%&\'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'));
var _user$project$Utils$isBlank = function (string) {
	return _elm_lang$core$String$isEmpty(
		_elm_lang$core$String$trim(string));
};
var _user$project$Utils$validateEmail = function (string) {
	return (!_user$project$Utils$isBlank(string)) && A2(_elm_lang$core$Regex$contains, _user$project$Utils$emailRegex, string);
};

var _user$project$Modal$modalContent = function (config) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('modal-content'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('modal-close-icon'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$a,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('close-modal'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(config.closeMessage),
								_1: {ctor: '[]'}
							}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$i,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('fa fa-times'),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$html$Html_Attributes$attribute, 'aria-hidden', 'true'),
										_1: {ctor: '[]'}
									}
								},
								{ctor: '[]'}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('modal-content-inner'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$h4,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(config.title),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: config.content,
							_1: {ctor: '[]'}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$hr,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('modal-buttons-seperator'),
							_1: {ctor: '[]'}
						},
						{ctor: '[]'}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('modal-buttons'),
								_1: {ctor: '[]'}
							},
							config.buttons),
						_1: {ctor: '[]'}
					}
				}
			}
		});
};
var _user$project$Modal$view = F2(
	function (modalId, maybeConfig) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id(modalId),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$classList(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'modal', _1: true},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'modal-open',
									_1: _krisajenkins$elm_exts$Exts_Maybe$isJust(maybeConfig)
								},
								_1: {ctor: '[]'}
							}
						}),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('modal-inner'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: function () {
							var _p0 = maybeConfig;
							if (_p0.ctor === 'Nothing') {
								return A2(
									_elm_lang$html$Html$div,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('modal-content'),
										_1: {ctor: '[]'}
									},
									{ctor: '[]'});
							} else {
								return _user$project$Modal$modalContent(_p0._0);
							}
						}(),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	});
var _user$project$Modal$Config = F4(
	function (a, b, c, d) {
		return {closeMessage: a, title: b, content: c, buttons: d};
	});

var _user$project$Components_SigninModal$initModel = {open: false, email: '', saveAnonymousCotos: false, requestProcessing: false, requestDone: false};
var _user$project$Components_SigninModal$Model = F5(
	function (a, b, c, d, e) {
		return {open: a, email: b, saveAnonymousCotos: c, requestProcessing: d, requestDone: e};
	});
var _user$project$Components_SigninModal$RequestDone = function (a) {
	return {ctor: 'RequestDone', _0: a};
};
var _user$project$Components_SigninModal$requestSignin = F2(
	function (email, saveAnonymous) {
		var url = A2(
			_elm_lang$core$Basics_ops['++'],
			'/api/signin/request/',
			A2(
				_elm_lang$core$Basics_ops['++'],
				email,
				saveAnonymous ? '/yes' : '/no'));
		return A2(
			_elm_lang$http$Http$send,
			_user$project$Components_SigninModal$RequestDone,
			A2(_elm_lang$http$Http$get, url, _elm_lang$core$Json_Decode$string));
	});
var _user$project$Components_SigninModal$update = F2(
	function (msg, model) {
		var _p0 = msg;
		switch (_p0.ctor) {
			case 'Close':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{open: false, requestDone: false}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'EmailInput':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{email: _p0._0}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'SaveAnonymousCotosCheck':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{saveAnonymousCotos: _p0._0}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'RequestClick':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{requestProcessing: true}),
					{
						ctor: '::',
						_0: A2(_user$project$Components_SigninModal$requestSignin, model.email, model.saveAnonymousCotos),
						_1: {ctor: '[]'}
					});
			default:
				if (_p0._0.ctor === 'Ok') {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{email: '', requestProcessing: false, requestDone: true}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{requestProcessing: false}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				}
		}
	});
var _user$project$Components_SigninModal$RequestClick = {ctor: 'RequestClick'};
var _user$project$Components_SigninModal$SaveAnonymousCotosCheck = function (a) {
	return {ctor: 'SaveAnonymousCotosCheck', _0: a};
};
var _user$project$Components_SigninModal$EmailInput = function (a) {
	return {ctor: 'EmailInput', _0: a};
};
var _user$project$Components_SigninModal$Close = {ctor: 'Close'};
var _user$project$Components_SigninModal$signinModalConfig = F2(
	function (model, showAnonymousOption) {
		return model.requestDone ? {
			closeMessage: _user$project$Components_SigninModal$Close,
			title: 'Check your inbox!',
			content: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$id('signin-modal-content'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('We just sent you an email with a link to access (or create) your Cotoami account.'),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			buttons: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$button,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('button'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Events$onClick(_user$project$Components_SigninModal$Close),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('OK'),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		} : {
			closeMessage: _user$project$Components_SigninModal$Close,
			title: 'Sign in with your email',
			content: A2(
				_elm_lang$html$Html$div,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$p,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('Cotoami doesn\'t use passwords. Just enter your email address and we\'ll send you a sign-in (or sign-up) link.'),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$form,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$name('signin'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$div,
									{ctor: '[]'},
									{
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$input,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$type_('email'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('u-full-width'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$name('email'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$placeholder('you@example.com'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$value(model.email),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Events$onInput(_user$project$Components_SigninModal$EmailInput),
																	_1: {ctor: '[]'}
																}
															}
														}
													}
												}
											},
											{ctor: '[]'}),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: showAnonymousOption ? A2(
										_elm_lang$html$Html$div,
										{ctor: '[]'},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$label,
												{ctor: '[]'},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$input,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$type_('checkbox'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Events$onCheck(_user$project$Components_SigninModal$SaveAnonymousCotosCheck),
																_1: {ctor: '[]'}
															}
														},
														{ctor: '[]'}),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$span,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('label-body'),
																_1: {ctor: '[]'}
															},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text('Save the anonymous cotos (posts) into your account'),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}
												}),
											_1: {ctor: '[]'}
										}) : A2(
										_elm_lang$html$Html$div,
										{ctor: '[]'},
										{ctor: '[]'}),
									_1: {ctor: '[]'}
								}
							}),
						_1: {ctor: '[]'}
					}
				}),
			buttons: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$button,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('button'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Events$onClick(_user$project$Components_SigninModal$Close),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Cancel'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$button,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('button button-primary'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$disabled(
									(!_user$project$Utils$validateEmail(model.email)) || model.requestProcessing),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onClick(_user$project$Components_SigninModal$RequestClick),
									_1: {ctor: '[]'}
								}
							}
						},
						{
							ctor: '::',
							_0: model.requestProcessing ? _elm_lang$html$Html$text('Sending...') : _elm_lang$html$Html$text('OK'),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			}
		};
	});
var _user$project$Components_SigninModal$view = F2(
	function (model, showAnonymousOption) {
		return A2(
			_user$project$Modal$view,
			'signin-modal',
			model.open ? _elm_lang$core$Maybe$Just(
				A2(_user$project$Components_SigninModal$signinModalConfig, model, showAnonymousOption)) : _elm_lang$core$Maybe$Nothing);
	});

var _user$project$Components_ProfileModal$update = F2(
	function (msg, model) {
		var _p0 = msg;
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_Utils.update(
				model,
				{open: false}),
			_1: _elm_lang$core$Platform_Cmd$none
		};
	});
var _user$project$Components_ProfileModal$initModel = {open: false};
var _user$project$Components_ProfileModal$Model = function (a) {
	return {open: a};
};
var _user$project$Components_ProfileModal$Close = {ctor: 'Close'};
var _user$project$Components_ProfileModal$modalConfig = F2(
	function (session, model) {
		return {
			closeMessage: _user$project$Components_ProfileModal$Close,
			title: 'Amishi Profile',
			content: A2(
				_elm_lang$html$Html$div,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('profile container'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('row'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$div,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('avatar-box three columns'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$a,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$href('https://gravatar.com/'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$target('_blank'),
														_1: {ctor: '[]'}
													}
												},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$img,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('avatar'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$src(session.avatarUrl),
																_1: {ctor: '[]'}
															}
														},
														{ctor: '[]'}),
													_1: {ctor: '[]'}
												}),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$div,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('profile-info nine columns'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$label,
													{ctor: '[]'},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('Name'),
														_1: {ctor: '[]'}
													}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$input,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$type_('text'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('u-full-width'),
																_1: {
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$value(session.displayName),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$disabled(true),
																		_1: {ctor: '[]'}
																	}
																}
															}
														},
														{ctor: '[]'}),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$label,
															{ctor: '[]'},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text('Email Address'),
																_1: {ctor: '[]'}
															}),
														_1: {
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$input,
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$type_('text'),
																	_1: {
																		ctor: '::',
																		_0: _elm_lang$html$Html_Attributes$class('u-full-width'),
																		_1: {
																			ctor: '::',
																			_0: _elm_lang$html$Html_Attributes$value(session.email),
																			_1: {
																				ctor: '::',
																				_0: _elm_lang$html$Html_Attributes$disabled(true),
																				_1: {ctor: '[]'}
																			}
																		}
																	}
																},
																{ctor: '[]'}),
															_1: {ctor: '[]'}
														}
													}
												}
											}),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			buttons: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('button'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$href('/signout'),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Sign out'),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		};
	});
var _user$project$Components_ProfileModal$view = F2(
	function (maybeSession, model) {
		return A2(
			_user$project$Modal$view,
			'profile-modal',
			function () {
				var _p1 = maybeSession;
				if (_p1.ctor === 'Nothing') {
					return _elm_lang$core$Maybe$Nothing;
				} else {
					return model.open ? _elm_lang$core$Maybe$Just(
						A2(_user$project$Components_ProfileModal$modalConfig, _p1._0, model)) : _elm_lang$core$Maybe$Nothing;
				}
			}());
	});

var _user$project$Components_Timeline_Model$updatePost = F3(
	function (update, cotoId, posts) {
		return A2(
			_elm_lang$core$List$map,
			function (post) {
				return _elm_lang$core$Native_Utils.eq(
					post.cotoId,
					_elm_lang$core$Maybe$Just(cotoId)) ? update(post) : post;
			},
			posts);
	});
var _user$project$Components_Timeline_Model$setLoading = function (model) {
	return _elm_lang$core$Native_Utils.update(
		model,
		{
			posts: {ctor: '[]'},
			loading: true
		});
};
var _user$project$Components_Timeline_Model$initModel = {
	editingNew: false,
	newContent: '',
	postIdCounter: 0,
	posts: {ctor: '[]'},
	loading: true
};
var _user$project$Components_Timeline_Model$isPostedInCoto = F2(
	function (coto, post) {
		if (coto.asCotonoma) {
			var _p0 = post.postedIn;
			if (_p0.ctor === 'Nothing') {
				return false;
			} else {
				return _elm_lang$core$Native_Utils.eq(_p0._0.key, coto.cotonomaKey);
			}
		} else {
			return false;
		}
	});
var _user$project$Components_Timeline_Model$isSelfOrPostedIn = F2(
	function (coto, post) {
		return _elm_lang$core$Native_Utils.eq(
			post.cotoId,
			_elm_lang$core$Maybe$Just(coto.id)) || A2(_user$project$Components_Timeline_Model$isPostedInCoto, coto, post);
	});
var _user$project$Components_Timeline_Model$isPostedInCotonoma = F2(
	function (maybeCotonoma, post) {
		var _p1 = maybeCotonoma;
		if (_p1.ctor === 'Nothing') {
			return _krisajenkins$elm_exts$Exts_Maybe$isNothing(post.postedIn);
		} else {
			var _p2 = post.postedIn;
			if (_p2.ctor === 'Nothing') {
				return false;
			} else {
				return _elm_lang$core$Native_Utils.eq(_p2._0.id, _p1._0.id);
			}
		}
	});
var _user$project$Components_Timeline_Model$toCoto = function (post) {
	var _p3 = post.cotoId;
	if (_p3.ctor === 'Nothing') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		return _elm_lang$core$Maybe$Just(
			A5(_user$project$App_Types$Coto, _p3._0, post.content, post.postedIn, post.asCotonoma, post.cotonomaKey));
	}
};
var _user$project$Components_Timeline_Model$defaultPost = {postId: _elm_lang$core$Maybe$Nothing, cotoId: _elm_lang$core$Maybe$Nothing, content: '', amishi: _elm_lang$core$Maybe$Nothing, postedIn: _elm_lang$core$Maybe$Nothing, asCotonoma: false, cotonomaKey: '', beingDeleted: false};
var _user$project$Components_Timeline_Model$Post = F8(
	function (a, b, c, d, e, f, g, h) {
		return {postId: a, cotoId: b, content: c, amishi: d, postedIn: e, asCotonoma: f, cotonomaKey: g, beingDeleted: h};
	});
var _user$project$Components_Timeline_Model$decodePost = A9(
	_elm_lang$core$Json_Decode$map8,
	_user$project$Components_Timeline_Model$Post,
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode$field, 'postId', _elm_lang$core$Json_Decode$int)),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode$field, 'id', _elm_lang$core$Json_Decode$int)),
	A2(_elm_lang$core$Json_Decode$field, 'content', _elm_lang$core$Json_Decode$string),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode$field, 'amishi', _user$project$App_Types$decodeAmishi)),
	_elm_lang$core$Json_Decode$maybe(
		A2(_elm_lang$core$Json_Decode$field, 'posted_in', _user$project$App_Types$decodeCotonoma)),
	A2(_elm_lang$core$Json_Decode$field, 'as_cotonoma', _elm_lang$core$Json_Decode$bool),
	A2(_elm_lang$core$Json_Decode$field, 'cotonoma_key', _elm_lang$core$Json_Decode$string),
	_elm_lang$core$Json_Decode$succeed(false));
var _user$project$Components_Timeline_Model$Model = F5(
	function (a, b, c, d, e) {
		return {editingNew: a, newContent: b, postIdCounter: c, posts: d, loading: e};
	});

var _user$project$Components_Timeline_Messages$CotonomaPushed = function (a) {
	return {ctor: 'CotonomaPushed', _0: a};
};
var _user$project$Components_Timeline_Messages$PostPushed = function (a) {
	return {ctor: 'PostPushed', _0: a};
};
var _user$project$Components_Timeline_Messages$CotonomaClick = function (a) {
	return {ctor: 'CotonomaClick', _0: a};
};
var _user$project$Components_Timeline_Messages$PostOpen = function (a) {
	return {ctor: 'PostOpen', _0: a};
};
var _user$project$Components_Timeline_Messages$Posted = function (a) {
	return {ctor: 'Posted', _0: a};
};
var _user$project$Components_Timeline_Messages$Post = {ctor: 'Post'};
var _user$project$Components_Timeline_Messages$EditorKeyDown = function (a) {
	return {ctor: 'EditorKeyDown', _0: a};
};
var _user$project$Components_Timeline_Messages$EditorInput = function (a) {
	return {ctor: 'EditorInput', _0: a};
};
var _user$project$Components_Timeline_Messages$EditorBlur = {ctor: 'EditorBlur'};
var _user$project$Components_Timeline_Messages$EditorFocus = {ctor: 'EditorFocus'};
var _user$project$Components_Timeline_Messages$PostClick = function (a) {
	return {ctor: 'PostClick', _0: a};
};
var _user$project$Components_Timeline_Messages$ImageLoaded = {ctor: 'ImageLoaded'};
var _user$project$Components_Timeline_Messages$PostsFetched = function (a) {
	return {ctor: 'PostsFetched', _0: a};
};
var _user$project$Components_Timeline_Messages$NoOp = {ctor: 'NoOp'};

var _user$project$Markdown_Config$imageElement = function (model) {
	var _p0 = model.title;
	if (_p0.ctor === 'Just') {
		return A2(
			_elm_lang$html$Html$img,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$alt(model.alt),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$src(model.src),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$title(_p0._0),
						_1: {ctor: '[]'}
					}
				}
			},
			{ctor: '[]'});
	} else {
		return A2(
			_elm_lang$html$Html$img,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$alt(model.alt),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$src(model.src),
					_1: {ctor: '[]'}
				}
			},
			{ctor: '[]'});
	}
};
var _user$project$Markdown_Config$linkElement = function (model) {
	var _p1 = model.title;
	if (_p1.ctor === 'Just') {
		return _elm_lang$html$Html$a(
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href(model.url),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$title(_p1._0),
					_1: {ctor: '[]'}
				}
			});
	} else {
		return _elm_lang$html$Html$a(
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href(model.url),
				_1: {ctor: '[]'}
			});
	}
};
var _user$project$Markdown_Config$codeSpanElement = function (codeStr) {
	return A2(
		_elm_lang$html$Html$code,
		{ctor: '[]'},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text(codeStr),
			_1: {ctor: '[]'}
		});
};
var _user$project$Markdown_Config$strongEmphasisElement = _elm_lang$html$Html$strong(
	{ctor: '[]'});
var _user$project$Markdown_Config$emphasisElement = _elm_lang$html$Html$em(
	{ctor: '[]'});
var _user$project$Markdown_Config$listElement = function (type_) {
	var _p2 = type_;
	if (_p2.ctor === 'Ordered') {
		var _p3 = _p2._0;
		return _elm_lang$core$Native_Utils.eq(_p3, 1) ? _elm_lang$html$Html$ol(
			{ctor: '[]'}) : _elm_lang$html$Html$ol(
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$start(_p3),
				_1: {ctor: '[]'}
			});
	} else {
		return _elm_lang$html$Html$ul(
			{ctor: '[]'});
	}
};
var _user$project$Markdown_Config$codeElement = function (codeBlock) {
	var basicView = function (attrs) {
		return A2(
			_elm_lang$html$Html$pre,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$code,
					attrs,
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(codeBlock.code),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	};
	var _p4 = codeBlock.language;
	if (_p4.ctor === 'Just') {
		return basicView(
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class(
					A2(_elm_lang$core$Basics_ops['++'], 'language-', _p4._0)),
				_1: {ctor: '[]'}
			});
	} else {
		return basicView(
			{ctor: '[]'});
	}
};
var _user$project$Markdown_Config$paragraphElement = F2(
	function (textAsParagraph, innerHtml) {
		return textAsParagraph ? {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$p,
				{ctor: '[]'},
				innerHtml),
			_1: {ctor: '[]'}
		} : innerHtml;
	});
var _user$project$Markdown_Config$headingElement = function (level) {
	var _p5 = level;
	switch (_p5) {
		case 1:
			return _elm_lang$html$Html$h1(
				{ctor: '[]'});
		case 2:
			return _elm_lang$html$Html$h2(
				{ctor: '[]'});
		case 3:
			return _elm_lang$html$Html$h3(
				{ctor: '[]'});
		case 4:
			return _elm_lang$html$Html$h4(
				{ctor: '[]'});
		case 5:
			return _elm_lang$html$Html$h5(
				{ctor: '[]'});
		default:
			return _elm_lang$html$Html$h6(
				{ctor: '[]'});
	}
};
var _user$project$Markdown_Config$defaultElements = {
	heading: _user$project$Markdown_Config$headingElement,
	thematicBreak: A2(
		_elm_lang$html$Html$hr,
		{ctor: '[]'},
		{ctor: '[]'}),
	paragraph: _user$project$Markdown_Config$paragraphElement,
	blockQuote: _elm_lang$html$Html$blockquote(
		{ctor: '[]'}),
	code: _user$project$Markdown_Config$codeElement,
	list: _user$project$Markdown_Config$listElement,
	emphasis: _user$project$Markdown_Config$emphasisElement,
	strongEmphasis: _user$project$Markdown_Config$strongEmphasisElement,
	codeSpan: _user$project$Markdown_Config$codeSpanElement,
	link: _user$project$Markdown_Config$linkElement,
	image: _user$project$Markdown_Config$imageElement,
	hardLineBreak: A2(
		_elm_lang$html$Html$br,
		{ctor: '[]'},
		{ctor: '[]'})
};
var _user$project$Markdown_Config$defaultAllowedHtmlAttributes = {
	ctor: '::',
	_0: 'name',
	_1: {
		ctor: '::',
		_0: 'class',
		_1: {ctor: '[]'}
	}
};
var _user$project$Markdown_Config$defaultAllowedHtmlElements = {
	ctor: '::',
	_0: 'address',
	_1: {
		ctor: '::',
		_0: 'article',
		_1: {
			ctor: '::',
			_0: 'aside',
			_1: {
				ctor: '::',
				_0: 'b',
				_1: {
					ctor: '::',
					_0: 'blockquote',
					_1: {
						ctor: '::',
						_0: 'br',
						_1: {
							ctor: '::',
							_0: 'caption',
							_1: {
								ctor: '::',
								_0: 'center',
								_1: {
									ctor: '::',
									_0: 'cite',
									_1: {
										ctor: '::',
										_0: 'code',
										_1: {
											ctor: '::',
											_0: 'col',
											_1: {
												ctor: '::',
												_0: 'colgroup',
												_1: {
													ctor: '::',
													_0: 'dd',
													_1: {
														ctor: '::',
														_0: 'details',
														_1: {
															ctor: '::',
															_0: 'div',
															_1: {
																ctor: '::',
																_0: 'dl',
																_1: {
																	ctor: '::',
																	_0: 'dt',
																	_1: {
																		ctor: '::',
																		_0: 'figcaption',
																		_1: {
																			ctor: '::',
																			_0: 'figure',
																			_1: {
																				ctor: '::',
																				_0: 'footer',
																				_1: {
																					ctor: '::',
																					_0: 'h1',
																					_1: {
																						ctor: '::',
																						_0: 'h2',
																						_1: {
																							ctor: '::',
																							_0: 'h3',
																							_1: {
																								ctor: '::',
																								_0: 'h4',
																								_1: {
																									ctor: '::',
																									_0: 'h5',
																									_1: {
																										ctor: '::',
																										_0: 'h6',
																										_1: {
																											ctor: '::',
																											_0: 'hr',
																											_1: {
																												ctor: '::',
																												_0: 'i',
																												_1: {
																													ctor: '::',
																													_0: 'legend',
																													_1: {
																														ctor: '::',
																														_0: 'li',
																														_1: {
																															ctor: '::',
																															_0: 'menu',
																															_1: {
																																ctor: '::',
																																_0: 'menuitem',
																																_1: {
																																	ctor: '::',
																																	_0: 'nav',
																																	_1: {
																																		ctor: '::',
																																		_0: 'ol',
																																		_1: {
																																			ctor: '::',
																																			_0: 'optgroup',
																																			_1: {
																																				ctor: '::',
																																				_0: 'option',
																																				_1: {
																																					ctor: '::',
																																					_0: 'p',
																																					_1: {
																																						ctor: '::',
																																						_0: 'pre',
																																						_1: {
																																							ctor: '::',
																																							_0: 'section',
																																							_1: {
																																								ctor: '::',
																																								_0: 'strike',
																																								_1: {
																																									ctor: '::',
																																									_0: 'summary',
																																									_1: {
																																										ctor: '::',
																																										_0: 'small',
																																										_1: {
																																											ctor: '::',
																																											_0: 'table',
																																											_1: {
																																												ctor: '::',
																																												_0: 'tbody',
																																												_1: {
																																													ctor: '::',
																																													_0: 'td',
																																													_1: {
																																														ctor: '::',
																																														_0: 'tfoot',
																																														_1: {
																																															ctor: '::',
																																															_0: 'th',
																																															_1: {
																																																ctor: '::',
																																																_0: 'thead',
																																																_1: {
																																																	ctor: '::',
																																																	_0: 'tr',
																																																	_1: {
																																																		ctor: '::',
																																																		_0: 'ul',
																																																		_1: {ctor: '[]'}
																																																	}
																																																}
																																															}
																																														}
																																													}
																																												}
																																											}
																																										}
																																									}
																																								}
																																							}
																																						}
																																					}
																																				}
																																			}
																																		}
																																	}
																																}
																															}
																														}
																													}
																												}
																											}
																										}
																									}
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _user$project$Markdown_Config$defaultSanitizeOptions = {allowedHtmlElements: _user$project$Markdown_Config$defaultAllowedHtmlElements, allowedHtmlAttributes: _user$project$Markdown_Config$defaultAllowedHtmlAttributes};
var _user$project$Markdown_Config$Options = F2(
	function (a, b) {
		return {softAsHardLineBreak: a, rawHtml: b};
	});
var _user$project$Markdown_Config$SanitizeOptions = F2(
	function (a, b) {
		return {allowedHtmlElements: a, allowedHtmlAttributes: b};
	});
var _user$project$Markdown_Config$Elements = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return function (l) {
												return {heading: a, thematicBreak: b, paragraph: c, blockQuote: d, code: e, list: f, emphasis: g, strongEmphasis: h, codeSpan: i, link: j, image: k, hardLineBreak: l};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _user$project$Markdown_Config$CodeBlock = F2(
	function (a, b) {
		return {language: a, code: b};
	});
var _user$project$Markdown_Config$Link = F2(
	function (a, b) {
		return {url: a, title: b};
	});
var _user$project$Markdown_Config$Image = F3(
	function (a, b, c) {
		return {alt: a, src: b, title: c};
	});
var _user$project$Markdown_Config$DontParse = {ctor: 'DontParse'};
var _user$project$Markdown_Config$Sanitize = function (a) {
	return {ctor: 'Sanitize', _0: a};
};
var _user$project$Markdown_Config$defaultOptions = {
	softAsHardLineBreak: false,
	rawHtml: _user$project$Markdown_Config$Sanitize(_user$project$Markdown_Config$defaultSanitizeOptions)
};
var _user$project$Markdown_Config$ParseUnsafe = {ctor: 'ParseUnsafe'};
var _user$project$Markdown_Config$Ordered = function (a) {
	return {ctor: 'Ordered', _0: a};
};
var _user$project$Markdown_Config$Unordered = {ctor: 'Unordered'};

var _user$project$Markdown_Inline$ifNothing = F2(
	function (maybe, maybe_) {
		return _elm_lang$core$Native_Utils.eq(maybe_, _elm_lang$core$Maybe$Nothing) ? maybe : maybe_;
	});
var _user$project$Markdown_Inline$returnFirstJust = function (maybes) {
	var process = F2(
		function (a, maybeFound) {
			var _p0 = maybeFound;
			if (_p0.ctor === 'Just') {
				return _elm_lang$core$Maybe$Just(_p0._0);
			} else {
				return a;
			}
		});
	return A3(_elm_lang$core$List$foldl, process, _elm_lang$core$Maybe$Nothing, maybes);
};
var _user$project$Markdown_Inline$escapableRegex = _elm_lang$core$Regex$regex('(\\\\+)([!\"#$%&\\\'()*+,./:;<=>?@[\\\\\\]^_`{|}~-])');
var _user$project$Markdown_Inline$replaceEscapable = A3(
	_elm_lang$core$Regex$replace,
	_elm_lang$core$Regex$All,
	_user$project$Markdown_Inline$escapableRegex,
	function (regexMatch) {
		var _p1 = regexMatch.submatches;
		if ((((_p1.ctor === '::') && (_p1._0.ctor === 'Just')) && (_p1._1.ctor === '::')) && (_p1._1._0.ctor === 'Just')) {
			return A2(
				_elm_lang$core$Basics_ops['++'],
				A2(
					_elm_lang$core$String$repeat,
					(_elm_lang$core$String$length(_p1._0._0) / 2) | 0,
					'\\'),
				_p1._1._0._0);
		} else {
			return regexMatch.match;
		}
	});
var _user$project$Markdown_Inline$whiteSpaceChars = ' \\t\\f\\v\\r\\n';
var _user$project$Markdown_Inline$cleanWhitespaces = function (_p2) {
	return A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_elm_lang$core$Regex$regex(
			A2(
				_elm_lang$core$Basics_ops['++'],
				'[',
				A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown_Inline$whiteSpaceChars, ']+'))),
		function (_p3) {
			return ' ';
		},
		_elm_lang$core$String$trim(_p2));
};
var _user$project$Markdown_Inline$attributeToAttribute = function (_p4) {
	var _p5 = _p4;
	var _p6 = _p5._0;
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		_p6,
		A2(_elm_lang$core$Maybe$withDefault, _p6, _p5._1));
};
var _user$project$Markdown_Inline$attributesToHtmlAttributes = _elm_lang$core$List$map(_user$project$Markdown_Inline$attributeToAttribute);
var _user$project$Markdown_Inline$isOpenEmphasisToken = F2(
	function (closeToken, openToken) {
		var _p7 = openToken.meaning;
		if ((_p7.ctor === 'EmphasisToken') && (_p7._1.ctor === '_Tuple2')) {
			var _p8 = closeToken.meaning;
			if ((_p8.ctor === 'EmphasisToken') && (_p8._1.ctor === '_Tuple2')) {
				return _elm_lang$core$Native_Utils.eq(_p7._0, _p8._0) ? ((_elm_lang$core$Native_Utils.eq(_p7._1._0, _p7._1._1) || _elm_lang$core$Native_Utils.eq(_p8._1._0, _p8._1._1)) ? (!_elm_lang$core$Native_Utils.eq(
					A2(_elm_lang$core$Basics_ops['%'], closeToken.length + openToken.length, 3),
					0)) : true) : false;
			} else {
				return false;
			}
		} else {
			return false;
		}
	});
var _user$project$Markdown_Inline$decodeUrlRegex = _elm_lang$core$Regex$regex('%(?:3B|2C|2F|3F|3A|40|26|3D|2B|24|23|25)');
var _user$project$Markdown_Inline$encodeUrl = function (_p9) {
	return A4(
		_elm_lang$core$Regex$replace,
		_elm_lang$core$Regex$All,
		_user$project$Markdown_Inline$decodeUrlRegex,
		function (match) {
			return A2(
				_elm_lang$core$Maybe$withDefault,
				match.match,
				_elm_lang$http$Http$decodeUri(match.match));
		},
		_elm_lang$http$Http$encodeUri(_p9));
};
var _user$project$Markdown_Inline$prepareRefLabel = function (_p10) {
	return _elm_lang$core$String$toLower(
		_user$project$Markdown_Inline$cleanWhitespaces(_p10));
};
var _user$project$Markdown_Inline$insideSquareBracketRegex = '[^\\[\\]\\\\]*(?:\\\\.[^\\[\\]\\\\]*)*';
var _user$project$Markdown_Inline$refLabelRegex = _elm_lang$core$Regex$regex(
	A2(
		_elm_lang$core$Basics_ops['++'],
		'^\\[\\s*(',
		A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown_Inline$insideSquareBracketRegex, ')\\s*\\]')));
var _user$project$Markdown_Inline$prepareUrlAndTitle = function (_p11) {
	var _p12 = _p11;
	return {
		ctor: '_Tuple2',
		_0: _user$project$Markdown_Inline$encodeUrl(
			_user$project$Markdown_Inline$replaceEscapable(_p12._0)),
		_1: A2(_elm_lang$core$Maybe$map, _user$project$Markdown_Inline$replaceEscapable, _p12._1)
	};
};
var _user$project$Markdown_Inline$titleRegex = A2(
	_elm_lang$core$Basics_ops['++'],
	'(?:[',
	A2(
		_elm_lang$core$Basics_ops['++'],
		_user$project$Markdown_Inline$whiteSpaceChars,
		A2(
			_elm_lang$core$Basics_ops['++'],
			']+',
			A2(
				_elm_lang$core$Basics_ops['++'],
				'(?:\'([^\'\\\\]*(?:\\\\.[^\'\\\\]*)*)\'|',
				A2(_elm_lang$core$Basics_ops['++'], '\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"|', '\\(([^\\)\\\\]*(?:\\\\.[^\\)\\\\]*)*)\\)))?')))));
var _user$project$Markdown_Inline$hrefRegex = A2(
	_elm_lang$core$Basics_ops['++'],
	'(?:<([^<>',
	A2(
		_elm_lang$core$Basics_ops['++'],
		_user$project$Markdown_Inline$whiteSpaceChars,
		A2(
			_elm_lang$core$Basics_ops['++'],
			']*)>|([^',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_user$project$Markdown_Inline$whiteSpaceChars,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'\\(\\)\\\\]*(?:\\\\.[^',
					A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown_Inline$whiteSpaceChars, '\\(\\)\\\\]*)*))'))))));
var _user$project$Markdown_Inline$inlineLinkOrImageRegex = _elm_lang$core$Regex$regex(
	A2(
		_elm_lang$core$Basics_ops['++'],
		'^\\(\\s*',
		A2(
			_elm_lang$core$Basics_ops['++'],
			_user$project$Markdown_Inline$hrefRegex,
			A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown_Inline$titleRegex, '\\s*\\)'))));
var _user$project$Markdown_Inline$removeParsedAheadTokens = F2(
	function (tokensTail, parser) {
		var _p13 = parser.matches;
		if (_p13.ctor === '[]') {
			return {ctor: '_Tuple2', _0: tokensTail, _1: parser};
		} else {
			return {
				ctor: '_Tuple2',
				_0: A2(
					_elm_lang$core$List$filter,
					function (token) {
						return _elm_lang$core$Native_Utils.cmp(token.index, _p13._0._0.end) > -1;
					},
					tokensTail),
				_1: parser
			};
		}
	});
var _user$project$Markdown_Inline$checkParsedAheadOverlapping = function (parser) {
	var _p14 = parser.matches;
	if (_p14.ctor === '[]') {
		return _elm_lang$core$Maybe$Nothing;
	} else {
		var _p19 = _p14._1;
		var _p18 = _p14._0._0;
		var overlappingMatches = A2(
			_elm_lang$core$List$filter,
			function (_p15) {
				var _p16 = _p15;
				var _p17 = _p16._0;
				return (_elm_lang$core$Native_Utils.cmp(_p18.end, _p17.start) > 0) && (_elm_lang$core$Native_Utils.cmp(_p18.end, _p17.end) < 0);
			},
			_p19);
		return (_elm_lang$core$List$isEmpty(_p19) || _elm_lang$core$List$isEmpty(overlappingMatches)) ? _elm_lang$core$Maybe$Just(parser) : _elm_lang$core$Maybe$Nothing;
	}
};
var _user$project$Markdown_Inline$isLinkOrImageOpenToken = function (token) {
	var _p20 = token.meaning;
	switch (_p20.ctor) {
		case 'LinkOpenToken':
			return true;
		case 'ImageOpenToken':
			return true;
		default:
			return false;
	}
};
var _user$project$Markdown_Inline$isCloseToken = F2(
	function (htmlModel, token) {
		var _p21 = token.meaning;
		if ((_p21.ctor === 'HtmlToken') && (_p21._0 === false)) {
			return _elm_lang$core$Native_Utils.eq(htmlModel.tag, _p21._1.tag);
		} else {
			return false;
		}
	});
var _user$project$Markdown_Inline$voidHtmlTags = {
	ctor: '::',
	_0: 'area',
	_1: {
		ctor: '::',
		_0: 'base',
		_1: {
			ctor: '::',
			_0: 'br',
			_1: {
				ctor: '::',
				_0: 'col',
				_1: {
					ctor: '::',
					_0: 'embed',
					_1: {
						ctor: '::',
						_0: 'hr',
						_1: {
							ctor: '::',
							_0: 'img',
							_1: {
								ctor: '::',
								_0: 'input',
								_1: {
									ctor: '::',
									_0: 'keygen',
									_1: {
										ctor: '::',
										_0: 'link',
										_1: {
											ctor: '::',
											_0: 'meta',
											_1: {
												ctor: '::',
												_0: 'param',
												_1: {
													ctor: '::',
													_0: 'source',
													_1: {
														ctor: '::',
														_0: 'track',
														_1: {
															ctor: '::',
															_0: 'wbr',
															_1: {ctor: '[]'}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _user$project$Markdown_Inline$isVoidTag = function (htmlModel) {
	return A2(_elm_lang$core$List$member, htmlModel.tag, _user$project$Markdown_Inline$voidHtmlTags);
};
var _user$project$Markdown_Inline$attributesFromRegex = function (regexMatch) {
	var _p22 = regexMatch.submatches;
	_v11_2:
	do {
		if ((_p22.ctor === '::') && (_p22._0.ctor === 'Just')) {
			if (_p22._0._0 === '') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				if (((_p22._1.ctor === '::') && (_p22._1._1.ctor === '::')) && (_p22._1._1._1.ctor === '::')) {
					var maybeValue = _user$project$Markdown_Inline$returnFirstJust(
						{
							ctor: '::',
							_0: _p22._1._0,
							_1: {
								ctor: '::',
								_0: _p22._1._1._0,
								_1: {
									ctor: '::',
									_0: _p22._1._1._1._0,
									_1: {ctor: '[]'}
								}
							}
						});
					return _elm_lang$core$Maybe$Just(
						{ctor: '_Tuple2', _0: _p22._0._0, _1: maybeValue});
				} else {
					break _v11_2;
				}
			}
		} else {
			break _v11_2;
		}
	} while(false);
	return _elm_lang$core$Maybe$Nothing;
};
var _user$project$Markdown_Inline$htmlAttributesRegex = _elm_lang$core$Regex$regex('([a-zA-Z:_][a-zA-Z0-9\\-_.:]*)(?: ?= ?(?:\"([^\"]*)\"|\'([^\']*)\'|([^\\s\"\'=<>`]*)))?');
var _user$project$Markdown_Inline$applyAttributesRegex = function (_p23) {
	return A2(
		_elm_lang$core$List$filterMap,
		_user$project$Markdown_Inline$attributesFromRegex,
		A3(_elm_lang$core$Regex$find, _elm_lang$core$Regex$All, _user$project$Markdown_Inline$htmlAttributesRegex, _p23));
};
var _user$project$Markdown_Inline$htmlRegex = _elm_lang$core$Regex$regex('^(\\/)?([a-zA-Z][a-zA-Z0-9\\-]*)(?:\\s+([^<>]*?))?(\\/)?$');
var _user$project$Markdown_Inline$emailRegex = _elm_lang$core$Regex$regex('^([a-zA-Z0-9.!#$%&\'*+\\/=?^_`{|}~\\-]+@[a-zA-Z0-9](?:[a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*)$');
var _user$project$Markdown_Inline$urlRegex = _elm_lang$core$Regex$regex('^([A-Za-z][A-Za-z0-9.+\\-]{1,31}:[^<>\\x00-\\x20]*)$');
var _user$project$Markdown_Inline$isCodeTokenPair = F2(
	function (closeToken, openToken) {
		var _p24 = openToken.meaning;
		if (_p24.ctor === 'CodeToken') {
			return _p24._0 ? _elm_lang$core$Native_Utils.eq(openToken.length - 1, closeToken.length) : _elm_lang$core$Native_Utils.eq(openToken.length, closeToken.length);
		} else {
			return false;
		}
	});
var _user$project$Markdown_Inline$applyTTM = F2(
	function (finderFunction, model) {
		return finderFunction(
			{
				ctor: '_Tuple2',
				_0: model.tokens,
				_1: _elm_lang$core$Native_Utils.update(
					model,
					{
						tokens: {ctor: '[]'}
					})
			});
	});
var _user$project$Markdown_Inline$containPunctuation = _elm_lang$core$Regex$contains(
	_elm_lang$core$Regex$regex('[!-#%-\\*,-/:;\\?@\\[-\\]_\\{\\}]'));
var _user$project$Markdown_Inline$containSpace = _elm_lang$core$Regex$contains(
	_elm_lang$core$Regex$regex('\\s'));
var _user$project$Markdown_Inline$charFringeRank = function ($char) {
	var string = _elm_lang$core$String$fromChar($char);
	return _user$project$Markdown_Inline$containSpace(string) ? 0 : (_user$project$Markdown_Inline$containPunctuation(string) ? 1 : 2);
};
var _user$project$Markdown_Inline$maybeCharFringeRank = function (maybeChar) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		0,
		A2(_elm_lang$core$Maybe$map, _user$project$Markdown_Inline$charFringeRank, maybeChar));
};
var _user$project$Markdown_Inline$calcFringeRank = F2(
	function (maybeLeft, _p25) {
		var _p26 = _p25;
		return {
			ctor: '_Tuple2',
			_0: _user$project$Markdown_Inline$maybeCharFringeRank(maybeLeft),
			_1: _user$project$Markdown_Inline$maybeCharFringeRank(
				_elm_lang$core$List$head(_p26._2))
		};
	});
var _user$project$Markdown_Inline$consToken = F3(
	function (model, meaning, _p27) {
		var _p28 = _p27;
		var _p29 = _p28._1;
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				remainChars: _p28._2,
				index: model.index + _p29,
				lastChar: _elm_lang$core$Maybe$Just(_p28._0),
				tokens: {
					ctor: '::',
					_0: {index: model.index, length: _p29, meaning: meaning},
					_1: model.tokens
				}
			});
	});
var _user$project$Markdown_Inline$consFringeRankedToken = F3(
	function (model, meaning, charCountRemain) {
		return function (type_) {
			return A3(_user$project$Markdown_Inline$consToken, model, type_, charCountRemain);
		}(
			meaning(
				A2(_user$project$Markdown_Inline$calcFringeRank, model.lastChar, charCountRemain)));
	});
var _user$project$Markdown_Inline$sameCharCount = function (_p30) {
	sameCharCount:
	while (true) {
		var _p31 = _p30;
		var _p35 = _p31._1;
		var _p34 = _p31._2;
		var _p33 = _p31._0;
		var _p32 = _p34;
		if (_p32.ctor === '[]') {
			return {ctor: '_Tuple3', _0: _p33, _1: _p35, _2: _p34};
		} else {
			if (_elm_lang$core$Native_Utils.eq(_p32._0, _p33)) {
				var _v17 = {ctor: '_Tuple3', _0: _p33, _1: _p35 + 1, _2: _p32._1};
				_p30 = _v17;
				continue sameCharCount;
			} else {
				return {ctor: '_Tuple3', _0: _p33, _1: _p35, _2: _p34};
			}
		}
	}
};
var _user$project$Markdown_Inline$reverseTokens = function (model) {
	return _elm_lang$core$Native_Utils.update(
		model,
		{
			tokens: _elm_lang$core$List$reverse(model.tokens)
		});
};
var _user$project$Markdown_Inline$filterTokens = F2(
	function (filter, model) {
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				tokens: A2(_elm_lang$core$List$filter, filter, model.tokens)
			});
	});
var _user$project$Markdown_Inline$addToken = F2(
	function (model, token) {
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				tokens: {ctor: '::', _0: token, _1: model.tokens}
			});
	});
var _user$project$Markdown_Inline$initTokenizer = function (rawText) {
	return {
		index: 0,
		lastChar: _elm_lang$core$Maybe$Nothing,
		isEscaped: false,
		remainChars: _elm_lang$core$String$toList(rawText),
		tokens: {ctor: '[]'}
	};
};
var _user$project$Markdown_Inline$findToken = F2(
	function (isToken, tokens) {
		var $return = function (_p36) {
			var _p37 = _p36;
			return A2(
				_elm_lang$core$Maybe$map,
				function (token) {
					return {
						ctor: '_Tuple3',
						_0: token,
						_1: _elm_lang$core$List$reverse(_p37._1),
						_2: _elm_lang$core$List$reverse(_p37._2)
					};
				},
				_p37._0);
		};
		var search = F2(
			function (token, _p38) {
				var _p39 = _p38;
				var _p42 = _p39._0;
				var _p41 = _p39._1;
				var _p40 = _p42;
				if (_p40.ctor === 'Nothing') {
					return isToken(token) ? {
						ctor: '_Tuple3',
						_0: _elm_lang$core$Maybe$Just(token),
						_1: _p41,
						_2: {ctor: '[]'}
					} : {
						ctor: '_Tuple3',
						_0: _elm_lang$core$Maybe$Nothing,
						_1: {ctor: '::', _0: token, _1: _p41},
						_2: {ctor: '[]'}
					};
				} else {
					return {
						ctor: '_Tuple3',
						_0: _p42,
						_1: _p41,
						_2: {ctor: '::', _0: token, _1: _p39._2}
					};
				}
			});
		return $return(
			A3(
				_elm_lang$core$List$foldl,
				search,
				{
					ctor: '_Tuple3',
					_0: _elm_lang$core$Maybe$Nothing,
					_1: {ctor: '[]'},
					_2: {ctor: '[]'}
				},
				tokens));
	});
var _user$project$Markdown_Inline$extractText = function (matches) {
	var extract = F2(
		function (_p43, text) {
			var _p44 = _p43;
			var _p46 = _p44._0;
			var _p45 = _p46.type_;
			switch (_p45.ctor) {
				case 'Normal':
					return A2(_elm_lang$core$Basics_ops['++'], text, _p46.text);
				case 'HardLineBreak':
					return A2(_elm_lang$core$Basics_ops['++'], text, ' ');
				default:
					return A2(
						_elm_lang$core$Basics_ops['++'],
						text,
						_user$project$Markdown_Inline$extractText(_p46.matches));
			}
		});
	return A3(_elm_lang$core$List$foldl, extract, '', matches);
};
var _user$project$Markdown_Inline$addMatch = F2(
	function (model, match) {
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				matches: {ctor: '::', _0: match, _1: model.matches}
			});
	});
var _user$project$Markdown_Inline$initParser = F3(
	function (options, refs, rawText) {
		return {
			rawText: rawText,
			tokens: {ctor: '[]'},
			matches: {ctor: '[]'},
			options: options,
			refs: refs
		};
	});
var _user$project$Markdown_Inline$Parser = F5(
	function (a, b, c, d, e) {
		return {rawText: a, tokens: b, matches: c, options: d, refs: e};
	});
var _user$project$Markdown_Inline$MatchModel = F7(
	function (a, b, c, d, e, f, g) {
		return {type_: a, start: b, end: c, textStart: d, textEnd: e, text: f, matches: g};
	});
var _user$project$Markdown_Inline$Token = F3(
	function (a, b, c) {
		return {index: a, length: b, meaning: c};
	});
var _user$project$Markdown_Inline$Tokenizer = F5(
	function (a, b, c, d, e) {
		return {index: a, lastChar: b, isEscaped: c, remainChars: d, tokens: e};
	});
var _user$project$Markdown_Inline$HtmlModel = F2(
	function (a, b) {
		return {tag: a, attributes: b};
	});
var _user$project$Markdown_Inline$Match = function (a) {
	return {ctor: 'Match', _0: a};
};
var _user$project$Markdown_Inline$prepareChildMatch = F2(
	function (parentMatch, childMatch) {
		return _user$project$Markdown_Inline$Match(
			_elm_lang$core$Native_Utils.update(
				childMatch,
				{start: childMatch.start - parentMatch.textStart, end: childMatch.end - parentMatch.textStart, textStart: childMatch.textStart - parentMatch.textStart, textEnd: childMatch.textEnd - parentMatch.textStart}));
	});
var _user$project$Markdown_Inline$addChild = F2(
	function (parentMatch, childMatch) {
		return _user$project$Markdown_Inline$Match(
			_elm_lang$core$Native_Utils.update(
				parentMatch,
				{
					matches: {
						ctor: '::',
						_0: A2(_user$project$Markdown_Inline$prepareChildMatch, parentMatch, childMatch),
						_1: parentMatch.matches
					}
				}));
	});
var _user$project$Markdown_Inline$organizeMatch = F2(
	function (_p47, matches) {
		var _p48 = _p47;
		var _p51 = _p48._0;
		var _p49 = matches;
		if (_p49.ctor === '[]') {
			return {
				ctor: '::',
				_0: _user$project$Markdown_Inline$Match(_p51),
				_1: {ctor: '[]'}
			};
		} else {
			var _p50 = _p49._0._0;
			return (_elm_lang$core$Native_Utils.cmp(_p50.end, _p51.start) < 1) ? {
				ctor: '::',
				_0: _user$project$Markdown_Inline$Match(_p51),
				_1: matches
			} : (((_elm_lang$core$Native_Utils.cmp(_p50.start, _p51.start) < 0) && (_elm_lang$core$Native_Utils.cmp(_p50.end, _p51.end) > 0)) ? {
				ctor: '::',
				_0: A2(_user$project$Markdown_Inline$addChild, _p50, _p51),
				_1: _p49._1
			} : matches);
		}
	});
var _user$project$Markdown_Inline$organizeMatches = function (_p52) {
	return A2(
		_elm_lang$core$List$map,
		function (_p53) {
			var _p54 = _p53;
			var _p55 = _p54._0;
			return _user$project$Markdown_Inline$Match(
				_elm_lang$core$Native_Utils.update(
					_p55,
					{
						matches: _user$project$Markdown_Inline$organizeMatches(_p55.matches)
					}));
		},
		A3(
			_elm_lang$core$List$foldl,
			_user$project$Markdown_Inline$organizeMatch,
			{ctor: '[]'},
			A2(
				_elm_lang$core$List$sortBy,
				function (_p56) {
					var _p57 = _p56;
					return _p57._0.start;
				},
				_p52)));
};
var _user$project$Markdown_Inline$organizeParserMatches = function (model) {
	return _elm_lang$core$Native_Utils.update(
		model,
		{
			matches: _user$project$Markdown_Inline$organizeMatches(model.matches)
		});
};
var _user$project$Markdown_Inline$tokenToMatch = F2(
	function (token, type_) {
		return _user$project$Markdown_Inline$Match(
			{
				type_: type_,
				start: token.index,
				end: token.index + token.length,
				textStart: 0,
				textEnd: 0,
				text: '',
				matches: {ctor: '[]'}
			});
	});
var _user$project$Markdown_Inline$Html = function (a) {
	return {ctor: 'Html', _0: a};
};
var _user$project$Markdown_Inline$Image = function (a) {
	return {ctor: 'Image', _0: a};
};
var _user$project$Markdown_Inline$Link = function (a) {
	return {ctor: 'Link', _0: a};
};
var _user$project$Markdown_Inline$inlineLinkOrImageRegexToMatch = F3(
	function (matchModel, model, regexMatch) {
		var _p58 = regexMatch.submatches;
		if (((((_p58.ctor === '::') && (_p58._1.ctor === '::')) && (_p58._1._1.ctor === '::')) && (_p58._1._1._1.ctor === '::')) && (_p58._1._1._1._1.ctor === '::')) {
			var maybeTitle = _user$project$Markdown_Inline$returnFirstJust(
				{
					ctor: '::',
					_0: _p58._1._1._0,
					_1: {
						ctor: '::',
						_0: _p58._1._1._1._0,
						_1: {
							ctor: '::',
							_0: _p58._1._1._1._1._0,
							_1: {ctor: '[]'}
						}
					}
				});
			var toMatch = function (rawUrl) {
				return _user$project$Markdown_Inline$Match(
					_elm_lang$core$Native_Utils.update(
						matchModel,
						{
							type_: function () {
								var _p59 = matchModel.type_;
								if (_p59.ctor === 'Image') {
									return _user$project$Markdown_Inline$Image;
								} else {
									return _user$project$Markdown_Inline$Link;
								}
							}()(
								_user$project$Markdown_Inline$prepareUrlAndTitle(
									{ctor: '_Tuple2', _0: rawUrl, _1: maybeTitle})),
							end: matchModel.end + _elm_lang$core$String$length(regexMatch.match)
						}));
			};
			var maybeRawUrl = _user$project$Markdown_Inline$returnFirstJust(
				{
					ctor: '::',
					_0: _p58._0,
					_1: {
						ctor: '::',
						_0: _p58._1._0,
						_1: {ctor: '[]'}
					}
				});
			return A2(_elm_lang$core$Maybe$map, toMatch, maybeRawUrl);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _user$project$Markdown_Inline$checkForInlineLinkOrImage = function (_p60) {
	var _p61 = _p60;
	var _p62 = _p61._2;
	return A2(
		_elm_lang$core$Maybe$map,
		_user$project$Markdown_Inline$addMatch(_p62),
		A2(
			_elm_lang$core$Maybe$andThen,
			A2(_user$project$Markdown_Inline$inlineLinkOrImageRegexToMatch, _p61._1._0, _p62),
			_elm_lang$core$List$head(
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_user$project$Markdown_Inline$inlineLinkOrImageRegex,
					_p61._0))));
};
var _user$project$Markdown_Inline$refRegexToMatch = F3(
	function (matchModel, model, maybeRegexMatch) {
		var regexMatchLength = A2(
			_elm_lang$core$Maybe$withDefault,
			0,
			A2(
				_elm_lang$core$Maybe$map,
				function (_p63) {
					return _elm_lang$core$String$length(
						function (_) {
							return _.match;
						}(_p63));
				},
				maybeRegexMatch));
		var toMatch = function (urlTitle) {
			return _user$project$Markdown_Inline$Match(
				_elm_lang$core$Native_Utils.update(
					matchModel,
					{
						type_: function () {
							var _p64 = matchModel.type_;
							if (_p64.ctor === 'Image') {
								return _user$project$Markdown_Inline$Image;
							} else {
								return _user$project$Markdown_Inline$Link;
							}
						}()(
							_user$project$Markdown_Inline$prepareUrlAndTitle(urlTitle)),
						end: matchModel.end + regexMatchLength
					}));
		};
		var refLabel = function (str) {
			return _elm_lang$core$String$isEmpty(str) ? matchModel.text : str;
		}(
			A2(
				_elm_lang$core$Maybe$withDefault,
				matchModel.text,
				A2(
					_elm_lang$core$Maybe$withDefault,
					_elm_lang$core$Maybe$Nothing,
					A2(
						_elm_lang$core$Maybe$withDefault,
						_elm_lang$core$Maybe$Nothing,
						A2(
							_elm_lang$core$Maybe$map,
							function (_p65) {
								return _elm_lang$core$List$head(
									function (_) {
										return _.submatches;
									}(_p65));
							},
							maybeRegexMatch)))));
		var maybeRefItem = A2(
			_elm_lang$core$Dict$get,
			_user$project$Markdown_Inline$prepareRefLabel(refLabel),
			model.refs);
		return A2(_elm_lang$core$Maybe$map, toMatch, maybeRefItem);
	});
var _user$project$Markdown_Inline$checkForRefLinkOrImage = function (_p66) {
	var _p67 = _p66;
	var _p68 = _p67._2;
	return A2(
		_elm_lang$core$Maybe$map,
		_user$project$Markdown_Inline$addMatch(_p68),
		A3(
			_user$project$Markdown_Inline$refRegexToMatch,
			_p67._1._0,
			_p68,
			_elm_lang$core$List$head(
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_user$project$Markdown_Inline$refLabelRegex,
					_p67._0))));
};
var _user$project$Markdown_Inline$Autolink = function (a) {
	return {ctor: 'Autolink', _0: a};
};
var _user$project$Markdown_Inline$autolinkToMatch = function (_p69) {
	var _p70 = _p69;
	var _p71 = _p70._0;
	return A2(_elm_lang$core$Regex$contains, _user$project$Markdown_Inline$urlRegex, _p71.text) ? _elm_lang$core$Maybe$Just(
		_user$project$Markdown_Inline$Match(
			_elm_lang$core$Native_Utils.update(
				_p71,
				{
					type_: _user$project$Markdown_Inline$Autolink(
						{
							ctor: '_Tuple2',
							_0: _p71.text,
							_1: _user$project$Markdown_Inline$encodeUrl(_p71.text)
						})
				}))) : _elm_lang$core$Maybe$Nothing;
};
var _user$project$Markdown_Inline$emailAutolinkToMatch = function (_p72) {
	var _p73 = _p72;
	var _p74 = _p73._0;
	return A2(_elm_lang$core$Regex$contains, _user$project$Markdown_Inline$emailRegex, _p74.text) ? _elm_lang$core$Maybe$Just(
		_user$project$Markdown_Inline$Match(
			_elm_lang$core$Native_Utils.update(
				_p74,
				{
					type_: _user$project$Markdown_Inline$Autolink(
						{
							ctor: '_Tuple2',
							_0: _p74.text,
							_1: A2(
								_elm_lang$core$Basics_ops['++'],
								'mailto:',
								_user$project$Markdown_Inline$encodeUrl(_p74.text))
						})
				}))) : _elm_lang$core$Maybe$Nothing;
};
var _user$project$Markdown_Inline$Emphasis = function (a) {
	return {ctor: 'Emphasis', _0: a};
};
var _user$project$Markdown_Inline$matchToHtml = F2(
	function (elements, _p75) {
		var _p76 = _p75;
		var _p80 = _p76._0;
		var _p77 = _p80.type_;
		switch (_p77.ctor) {
			case 'Normal':
				return _elm_lang$html$Html$text(_p80.text);
			case 'HardLineBreak':
				return elements.hardLineBreak;
			case 'Code':
				return elements.codeSpan(_p80.text);
			case 'Emphasis':
				var _p79 = _p77._0;
				var _p78 = _p79;
				switch (_p78) {
					case 1:
						return elements.emphasis(
							A2(_user$project$Markdown_Inline$toHtml, elements, _p80.matches));
					case 2:
						return elements.strongEmphasis(
							A2(_user$project$Markdown_Inline$toHtml, elements, _p80.matches));
					default:
						return (_elm_lang$core$Native_Utils.cmp(_p79 - 2, 0) > 0) ? elements.strongEmphasis(
							A3(
								_elm_lang$core$Basics$flip,
								F2(
									function (x, y) {
										return {ctor: '::', _0: x, _1: y};
									}),
								{ctor: '[]'},
								A2(
									_user$project$Markdown_Inline$matchToHtml,
									elements,
									_user$project$Markdown_Inline$Match(
										_elm_lang$core$Native_Utils.update(
											_p80,
											{
												type_: _user$project$Markdown_Inline$Emphasis(_p79 - 2)
											}))))) : elements.emphasis(
							A2(_user$project$Markdown_Inline$toHtml, elements, _p80.matches));
				}
			case 'Autolink':
				return A2(
					elements.link,
					{url: _p77._0._1, title: _elm_lang$core$Maybe$Nothing},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(_p77._0._0),
						_1: {ctor: '[]'}
					});
			case 'Link':
				return A2(
					elements.link,
					{url: _p77._0._0, title: _p77._0._1},
					A2(_user$project$Markdown_Inline$toHtml, elements, _p80.matches));
			case 'Image':
				return elements.image(
					{
						alt: _user$project$Markdown_Inline$extractText(_p80.matches),
						src: _p77._0._0,
						title: _p77._0._1
					});
			default:
				return A3(
					_elm_lang$html$Html$node,
					_p77._0.tag,
					_user$project$Markdown_Inline$attributesToHtmlAttributes(_p77._0.attributes),
					A2(_user$project$Markdown_Inline$toHtml, elements, _p80.matches));
		}
	});
var _user$project$Markdown_Inline$toHtml = function (elements) {
	return _elm_lang$core$List$map(
		_user$project$Markdown_Inline$matchToHtml(elements));
};
var _user$project$Markdown_Inline$Code = {ctor: 'Code'};
var _user$project$Markdown_Inline$HardLineBreak = {ctor: 'HardLineBreak'};
var _user$project$Markdown_Inline$Normal = {ctor: 'Normal'};
var _user$project$Markdown_Inline$normalMatch = function (text) {
	return _user$project$Markdown_Inline$Match(
		{
			type_: _user$project$Markdown_Inline$Normal,
			start: 0,
			end: 0,
			textStart: 0,
			textEnd: 0,
			text: _user$project$Markdown_Inline$replaceEscapable(text),
			matches: {ctor: '[]'}
		});
};
var _user$project$Markdown_Inline$parseTextMatch = F3(
	function (rawText, _p81, parsedMatches) {
		var _p82 = _p81;
		var _p85 = _p82._0;
		var updtMatch = _user$project$Markdown_Inline$Match(
			_elm_lang$core$Native_Utils.update(
				_p85,
				{
					matches: A3(
						_user$project$Markdown_Inline$parseTextMatches,
						_p85.text,
						{ctor: '[]'},
						_p85.matches)
				}));
		var _p83 = parsedMatches;
		if (_p83.ctor === '[]') {
			var finalStr = A2(_elm_lang$core$String$dropLeft, _p85.end, rawText);
			return _elm_lang$core$String$isEmpty(finalStr) ? {
				ctor: '::',
				_0: updtMatch,
				_1: {ctor: '[]'}
			} : {
				ctor: '::',
				_0: updtMatch,
				_1: {
					ctor: '::',
					_0: _user$project$Markdown_Inline$normalMatch(finalStr),
					_1: {ctor: '[]'}
				}
			};
		} else {
			var _p84 = _p83._0._0;
			return _elm_lang$core$Native_Utils.eq(_p84.type_, _user$project$Markdown_Inline$Normal) ? {ctor: '::', _0: updtMatch, _1: parsedMatches} : (_elm_lang$core$Native_Utils.eq(_p85.end, _p84.start) ? {ctor: '::', _0: updtMatch, _1: parsedMatches} : ((_elm_lang$core$Native_Utils.cmp(_p85.end, _p84.start) < 0) ? {
				ctor: '::',
				_0: updtMatch,
				_1: {
					ctor: '::',
					_0: _user$project$Markdown_Inline$normalMatch(
						A3(_elm_lang$core$String$slice, _p85.end, _p84.start, rawText)),
					_1: parsedMatches
				}
			} : parsedMatches));
		}
	});
var _user$project$Markdown_Inline$parseTextMatches = F3(
	function (rawText, parsedMatches, matches) {
		parseTextMatches:
		while (true) {
			var _p86 = matches;
			if (_p86.ctor === '[]') {
				var _p87 = parsedMatches;
				if (_p87.ctor === '[]') {
					return _elm_lang$core$String$isEmpty(rawText) ? {ctor: '[]'} : {
						ctor: '::',
						_0: _user$project$Markdown_Inline$normalMatch(rawText),
						_1: {ctor: '[]'}
					};
				} else {
					var _p88 = _p87._0._0;
					return (_elm_lang$core$Native_Utils.cmp(_p88.start, 0) > 0) ? {
						ctor: '::',
						_0: _user$project$Markdown_Inline$normalMatch(
							A2(_elm_lang$core$String$left, _p88.start, rawText)),
						_1: parsedMatches
					} : parsedMatches;
				}
			} else {
				var _v41 = rawText,
					_v42 = A3(_user$project$Markdown_Inline$parseTextMatch, rawText, _p86._0, parsedMatches),
					_v43 = _p86._1;
				rawText = _v41;
				parsedMatches = _v42;
				matches = _v43;
				continue parseTextMatches;
			}
		}
	});
var _user$project$Markdown_Inline$parseText = function (model) {
	return _elm_lang$core$Native_Utils.update(
		model,
		{
			matches: A3(
				_user$project$Markdown_Inline$parseTextMatches,
				model.rawText,
				{ctor: '[]'},
				model.matches)
		});
};
var _user$project$Markdown_Inline$HardLineBreakToken = {ctor: 'HardLineBreakToken'};
var _user$project$Markdown_Inline$SoftLineBreakToken = {ctor: 'SoftLineBreakToken'};
var _user$project$Markdown_Inline$lineBreakTTM = function (_p89) {
	lineBreakTTM:
	while (true) {
		var _p90 = _p89;
		var _p94 = _p90._1;
		var _p91 = _p90._0;
		if (_p91.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(_p94);
		} else {
			var _p93 = _p91._1;
			var _p92 = _p91._0;
			if (_elm_lang$core$Native_Utils.eq(_p92.meaning, _user$project$Markdown_Inline$HardLineBreakToken) || (_elm_lang$core$Native_Utils.eq(_p92.meaning, _user$project$Markdown_Inline$SoftLineBreakToken) && _p94.options.softAsHardLineBreak)) {
				var _v46 = A2(
					F2(
						function (v0, v1) {
							return {ctor: '_Tuple2', _0: v0, _1: v1};
						}),
					_p93,
					_elm_lang$core$Native_Utils.update(
						_p94,
						{
							matches: {
								ctor: '::',
								_0: A2(_user$project$Markdown_Inline$tokenToMatch, _p92, _user$project$Markdown_Inline$HardLineBreak),
								_1: _p94.matches
							}
						}));
				_p89 = _v46;
				continue lineBreakTTM;
			} else {
				var _v47 = {
					ctor: '_Tuple2',
					_0: _p93,
					_1: A2(_user$project$Markdown_Inline$addToken, _p94, _p92)
				};
				_p89 = _v47;
				continue lineBreakTTM;
			}
		}
	}
};
var _user$project$Markdown_Inline$EmphasisToken = F2(
	function (a, b) {
		return {ctor: 'EmphasisToken', _0: a, _1: b};
	});
var _user$project$Markdown_Inline$HtmlToken = F2(
	function (a, b) {
		return {ctor: 'HtmlToken', _0: a, _1: b};
	});
var _user$project$Markdown_Inline$htmlFromRegex = F3(
	function (model, match, regexMatch) {
		var _p95 = regexMatch.submatches;
		_v48_2:
		do {
			if (((_p95.ctor === '::') && (_p95._1.ctor === '::')) && (_p95._1._0.ctor === 'Just')) {
				if (_p95._1._0._0 === '') {
					return _elm_lang$core$Maybe$Nothing;
				} else {
					if ((_p95._1._1.ctor === '::') && (_p95._1._1._1.ctor === '::')) {
						var _p98 = _p95._1._0._0;
						var _p97 = _p95._0;
						var filterAttributes = F2(
							function (attrs, allowed) {
								return A2(
									_elm_lang$core$List$filter,
									function (attr) {
										return A2(
											_elm_lang$core$List$member,
											_elm_lang$core$Tuple$first(attr),
											allowed);
									},
									attrs);
							});
						var attributes = A2(
							_elm_lang$core$Maybe$withDefault,
							{ctor: '[]'},
							A2(_elm_lang$core$Maybe$map, _user$project$Markdown_Inline$applyAttributesRegex, _p95._1._1._0));
						var noAttributesInCloseTag = _elm_lang$core$Native_Utils.eq(_p97, _elm_lang$core$Maybe$Nothing) || ((!_elm_lang$core$Native_Utils.eq(_p97, _elm_lang$core$Maybe$Nothing)) && _elm_lang$core$Native_Utils.eq(
							attributes,
							{ctor: '[]'}));
						var updateModel = function (attrs) {
							return A2(
								_user$project$Markdown_Inline$addToken,
								model,
								{
									index: match.start,
									length: match.end - match.start,
									meaning: A2(
										_user$project$Markdown_Inline$HtmlToken,
										_elm_lang$core$Native_Utils.eq(_p97, _elm_lang$core$Maybe$Nothing) && _elm_lang$core$Native_Utils.eq(_p95._1._1._1._0, _elm_lang$core$Maybe$Nothing),
										A2(_user$project$Markdown_Inline$HtmlModel, _p98, attrs))
								});
						};
						var _p96 = model.options.rawHtml;
						switch (_p96.ctor) {
							case 'ParseUnsafe':
								return noAttributesInCloseTag ? _elm_lang$core$Maybe$Just(
									updateModel(attributes)) : _elm_lang$core$Maybe$Nothing;
							case 'Sanitize':
								return (A2(_elm_lang$core$List$member, _p98, _p96._0.allowedHtmlElements) && noAttributesInCloseTag) ? _elm_lang$core$Maybe$Just(
									updateModel(
										A2(filterAttributes, attributes, _p96._0.allowedHtmlAttributes))) : _elm_lang$core$Maybe$Nothing;
							default:
								return _elm_lang$core$Maybe$Nothing;
						}
					} else {
						break _v48_2;
					}
				}
			} else {
				break _v48_2;
			}
		} while(false);
		return _elm_lang$core$Maybe$Nothing;
	});
var _user$project$Markdown_Inline$htmlToToken = F2(
	function (model, _p99) {
		var _p100 = _p99;
		var _p102 = _p100._0;
		var _p101 = model.options.rawHtml;
		if (_p101.ctor === 'DontParse') {
			return _elm_lang$core$Maybe$Nothing;
		} else {
			return A2(
				_elm_lang$core$Maybe$andThen,
				A2(_user$project$Markdown_Inline$htmlFromRegex, model, _p102),
				_elm_lang$core$List$head(
					A3(
						_elm_lang$core$Regex$find,
						_elm_lang$core$Regex$AtMost(1),
						_user$project$Markdown_Inline$htmlRegex,
						_p102.text)));
		}
	});
var _user$project$Markdown_Inline$RightAngleBracket = function (a) {
	return {ctor: 'RightAngleBracket', _0: a};
};
var _user$project$Markdown_Inline$CharToken = function (a) {
	return {ctor: 'CharToken', _0: a};
};
var _user$project$Markdown_Inline$ImageOpenToken = {ctor: 'ImageOpenToken'};
var _user$project$Markdown_Inline$LinkOpenToken = function (a) {
	return {ctor: 'LinkOpenToken', _0: a};
};
var _user$project$Markdown_Inline$CodeToken = function (a) {
	return {ctor: 'CodeToken', _0: a};
};
var _user$project$Markdown_Inline$tokenizer = function (model) {
	tokenizer:
	while (true) {
		var _p103 = model.remainChars;
		if (_p103.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(model);
		} else {
			switch (_p103._0.valueOf()) {
				case '\n':
					var _p104 = _p103._1;
					if (model.isEscaped) {
						var _v53 = A3(
							_user$project$Markdown_Inline$consToken,
							_elm_lang$core$Native_Utils.update(
								model,
								{isEscaped: false, index: model.index - 1}),
							_user$project$Markdown_Inline$HardLineBreakToken,
							{
								ctor: '_Tuple3',
								_0: _elm_lang$core$Native_Utils.chr('\n'),
								_1: 2,
								_2: _p104
							});
						model = _v53;
						continue tokenizer;
					} else {
						return function (model) {
							return _user$project$Markdown_Inline$tokenizer(
								_elm_lang$core$Native_Utils.update(
									model,
									{isEscaped: false}));
						}(
							A3(
								_user$project$Markdown_Inline$consToken,
								model,
								_user$project$Markdown_Inline$SoftLineBreakToken,
								{
									ctor: '_Tuple3',
									_0: _elm_lang$core$Native_Utils.chr('\n'),
									_1: 1,
									_2: _p104
								}));
					}
				case '`':
					return function (model) {
						return _user$project$Markdown_Inline$tokenizer(
							_elm_lang$core$Native_Utils.update(
								model,
								{isEscaped: false}));
					}(
						A3(
							_user$project$Markdown_Inline$consToken,
							model,
							_user$project$Markdown_Inline$CodeToken(model.isEscaped),
							_user$project$Markdown_Inline$sameCharCount(
								{
									ctor: '_Tuple3',
									_0: _elm_lang$core$Native_Utils.chr('`'),
									_1: 1,
									_2: _p103._1
								})));
				case '>':
					return function (model) {
						return _user$project$Markdown_Inline$tokenizer(
							_elm_lang$core$Native_Utils.update(
								model,
								{isEscaped: false}));
					}(
						A3(
							_user$project$Markdown_Inline$consToken,
							model,
							_user$project$Markdown_Inline$RightAngleBracket(model.isEscaped),
							{
								ctor: '_Tuple3',
								_0: _elm_lang$core$Native_Utils.chr('>'),
								_1: 1,
								_2: _p103._1
							}));
				default:
					if (model.isEscaped) {
						var _v54 = _elm_lang$core$Native_Utils.update(
							model,
							{
								remainChars: _p103._1,
								index: model.index + 1,
								isEscaped: false,
								lastChar: _elm_lang$core$Maybe$Just(_p103._0)
							});
						model = _v54;
						continue tokenizer;
					} else {
						return _user$project$Markdown_Inline$unescapedTokenizer(model);
					}
			}
		}
	}
};
var _user$project$Markdown_Inline$unescapedTokenizer = function (model) {
	var _p105 = model.remainChars;
	_v55_4:
	do {
		if (_p105.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(model);
		} else {
			switch (_p105._0.valueOf()) {
				case ' ':
					if ((((_p105._1.ctor === '::') && (_p105._1._0.valueOf() === ' ')) && (_p105._1._1.ctor === '::')) && (_p105._1._1._0.valueOf() === '\n')) {
						return _user$project$Markdown_Inline$tokenizer(
							A3(
								_user$project$Markdown_Inline$consToken,
								model,
								_user$project$Markdown_Inline$HardLineBreakToken,
								{
									ctor: '_Tuple3',
									_0: _elm_lang$core$Native_Utils.chr('\n'),
									_1: 3,
									_2: _p105._1._1._1
								}));
					} else {
						break _v55_4;
					}
				case '!':
					if ((_p105._1.ctor === '::') && (_p105._1._0.valueOf() === '[')) {
						return _user$project$Markdown_Inline$tokenizer(
							A3(
								_user$project$Markdown_Inline$consToken,
								model,
								_user$project$Markdown_Inline$ImageOpenToken,
								{
									ctor: '_Tuple3',
									_0: _elm_lang$core$Native_Utils.chr('['),
									_1: 2,
									_2: _p105._1._1
								}));
					} else {
						break _v55_4;
					}
				case '[':
					return _user$project$Markdown_Inline$tokenizer(
						A3(
							_user$project$Markdown_Inline$consToken,
							model,
							_user$project$Markdown_Inline$LinkOpenToken(true),
							{
								ctor: '_Tuple3',
								_0: _elm_lang$core$Native_Utils.chr('['),
								_1: 1,
								_2: _p105._1
							}));
				default:
					break _v55_4;
			}
		}
	} while(false);
	var _p107 = _p105._1;
	var _p106 = _p105._0;
	return (_elm_lang$core$Native_Utils.eq(
		_p106,
		_elm_lang$core$Native_Utils.chr('*')) || _elm_lang$core$Native_Utils.eq(
		_p106,
		_elm_lang$core$Native_Utils.chr('_'))) ? _user$project$Markdown_Inline$tokenizer(
		A3(
			_user$project$Markdown_Inline$consFringeRankedToken,
			model,
			_user$project$Markdown_Inline$EmphasisToken(_p106),
			_user$project$Markdown_Inline$sameCharCount(
				{ctor: '_Tuple3', _0: _p106, _1: 1, _2: _p107}))) : ((_elm_lang$core$Native_Utils.eq(
		_p106,
		_elm_lang$core$Native_Utils.chr('<')) || _elm_lang$core$Native_Utils.eq(
		_p106,
		_elm_lang$core$Native_Utils.chr(']'))) ? _user$project$Markdown_Inline$tokenizer(
		A3(
			_user$project$Markdown_Inline$consToken,
			model,
			_user$project$Markdown_Inline$CharToken(_p106),
			{ctor: '_Tuple3', _0: _p106, _1: 1, _2: _p107})) : _user$project$Markdown_Inline$tokenizer(
		_elm_lang$core$Native_Utils.update(
			model,
			{
				remainChars: _p107,
				index: model.index + 1,
				isEscaped: _elm_lang$core$Native_Utils.eq(
					_p106,
					_elm_lang$core$Native_Utils.chr('\\')),
				lastChar: _elm_lang$core$Maybe$Just(_p106)
			})));
};
var _user$project$Markdown_Inline$tokenize = function (model) {
	return function (tokenizer) {
		return _elm_lang$core$Native_Utils.update(
			model,
			{tokens: tokenizer.tokens});
	}(
		_user$project$Markdown_Inline$tokenizer(
			_user$project$Markdown_Inline$initTokenizer(model.rawText)));
};
var _user$project$Markdown_Inline$codeToMatch = F3(
	function (closeToken, model, _p108) {
		var _p109 = _p108;
		var _p110 = _p109._0;
		var updtOpenToken = _elm_lang$core$Native_Utils.eq(
			_p110.meaning,
			_user$project$Markdown_Inline$CodeToken(true)) ? _elm_lang$core$Native_Utils.update(
			_p110,
			{index: _p110.index + 1, length: _p110.length - 1}) : _p110;
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				matches: {
					ctor: '::',
					_0: A6(
						_user$project$Markdown_Inline$tokenPairToMatch,
						model,
						_user$project$Markdown_Inline$cleanWhitespaces,
						_user$project$Markdown_Inline$Code,
						updtOpenToken,
						closeToken,
						{ctor: '[]'}),
					_1: model.matches
				},
				tokens: _p109._2
			});
	});
var _user$project$Markdown_Inline$tokenPairToMatch = F6(
	function (model, processText, type_, openToken, closeToken, innerTokens) {
		var textEnd = closeToken.index;
		var textStart = openToken.index + openToken.length;
		var end = closeToken.index + closeToken.length;
		var start = openToken.index;
		var match = {
			type_: type_,
			start: start,
			end: end,
			textStart: textStart,
			textEnd: textEnd,
			text: processText(
				A3(_elm_lang$core$String$slice, textStart, textEnd, model.rawText)),
			matches: {ctor: '[]'}
		};
		var matches = A2(
			_elm_lang$core$List$map,
			function (_p111) {
				var _p112 = _p111;
				return A2(_user$project$Markdown_Inline$prepareChildMatch, match, _p112._0);
			},
			function (_) {
				return _.matches;
			}(
				_user$project$Markdown_Inline$tokensToMatches(
					_elm_lang$core$Native_Utils.update(
						model,
						{
							tokens: innerTokens,
							matches: {ctor: '[]'}
						}))));
		return _user$project$Markdown_Inline$Match(
			_elm_lang$core$Native_Utils.update(
				match,
				{matches: matches}));
	});
var _user$project$Markdown_Inline$tokensToMatches = function (_p113) {
	return A2(
		_user$project$Markdown_Inline$applyTTM,
		_user$project$Markdown_Inline$lineBreakTTM,
		A2(
			_user$project$Markdown_Inline$applyTTM,
			_user$project$Markdown_Inline$emphasisTTM,
			A2(
				_user$project$Markdown_Inline$applyTTM,
				_user$project$Markdown_Inline$linkImageTTM,
				A2(
					_user$project$Markdown_Inline$applyTTM,
					_user$project$Markdown_Inline$htmlElementTTM,
					A2(_user$project$Markdown_Inline$applyTTM, _user$project$Markdown_Inline$codeAutolinkHtmlTagTTM, _p113)))));
};
var _user$project$Markdown_Inline$codeAutolinkHtmlTagTTM = function (_p114) {
	codeAutolinkHtmlTagTTM:
	while (true) {
		var _p115 = _p114;
		var _p122 = _p115._1;
		var _p116 = _p115._0;
		if (_p116.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(_p122);
		} else {
			var _p121 = _p116._1;
			var _p120 = _p116._0;
			var _p117 = _p120.meaning;
			switch (_p117.ctor) {
				case 'CodeToken':
					var _v61 = A2(
						F2(
							function (v0, v1) {
								return {ctor: '_Tuple2', _0: v0, _1: v1};
							}),
						_p121,
						A2(
							_elm_lang$core$Maybe$withDefault,
							A2(_user$project$Markdown_Inline$addToken, _p122, _p120),
							A2(
								_elm_lang$core$Maybe$map,
								A2(_user$project$Markdown_Inline$codeToMatch, _p120, _p122),
								A2(
									_user$project$Markdown_Inline$findToken,
									_user$project$Markdown_Inline$isCodeTokenPair(_p120),
									_p122.tokens))));
					_p114 = _v61;
					continue codeAutolinkHtmlTagTTM;
				case 'RightAngleBracket':
					var _v62 = A2(
						F2(
							function (v0, v1) {
								return {ctor: '_Tuple2', _0: v0, _1: v1};
							}),
						_p121,
						A2(
							_user$project$Markdown_Inline$filterTokens,
							function (_p118) {
								return A2(
									F2(
										function (x, y) {
											return !_elm_lang$core$Native_Utils.eq(x, y);
										}),
									_user$project$Markdown_Inline$CharToken(
										_elm_lang$core$Native_Utils.chr('<')),
									function (_) {
										return _.meaning;
									}(_p118));
							},
							A2(
								_elm_lang$core$Maybe$withDefault,
								_p122,
								A2(
									_elm_lang$core$Maybe$andThen,
									A3(_user$project$Markdown_Inline$angleBracketsToMatch, _p120, _p117._0, _p122),
									A2(
										_user$project$Markdown_Inline$findToken,
										function (_p119) {
											return A2(
												F2(
													function (x, y) {
														return _elm_lang$core$Native_Utils.eq(x, y);
													}),
												_user$project$Markdown_Inline$CharToken(
													_elm_lang$core$Native_Utils.chr('<')),
												function (_) {
													return _.meaning;
												}(_p119));
										},
										_p122.tokens)))));
					_p114 = _v62;
					continue codeAutolinkHtmlTagTTM;
				default:
					var _v63 = {
						ctor: '_Tuple2',
						_0: _p121,
						_1: A2(_user$project$Markdown_Inline$addToken, _p122, _p120)
					};
					_p114 = _v63;
					continue codeAutolinkHtmlTagTTM;
			}
		}
	}
};
var _user$project$Markdown_Inline$angleBracketsToMatch = F4(
	function (closeToken, isEscaped, model, _p123) {
		var _p124 = _p123;
		var _p125 = _p124._2;
		var tempMatch = A6(
			_user$project$Markdown_Inline$tokenPairToMatch,
			model,
			function (s) {
				return s;
			},
			_user$project$Markdown_Inline$Code,
			_p124._0,
			closeToken,
			{ctor: '[]'});
		return function (maybeModel) {
			return ((!isEscaped) && _elm_lang$core$Native_Utils.eq(maybeModel, _elm_lang$core$Maybe$Nothing)) ? A2(
				_user$project$Markdown_Inline$htmlToToken,
				_elm_lang$core$Native_Utils.update(
					model,
					{tokens: _p125}),
				tempMatch) : maybeModel;
		}(
			A2(
				_elm_lang$core$Maybe$map,
				function (newMatch) {
					return _elm_lang$core$Native_Utils.update(
						model,
						{
							matches: {ctor: '::', _0: newMatch, _1: model.matches},
							tokens: _p125
						});
				},
				A2(
					_user$project$Markdown_Inline$ifNothing,
					_user$project$Markdown_Inline$emailAutolinkToMatch(tempMatch),
					_user$project$Markdown_Inline$autolinkToMatch(tempMatch))));
	});
var _user$project$Markdown_Inline$emphasisTTM = function (_p126) {
	emphasisTTM:
	while (true) {
		var _p127 = _p126;
		var _p134 = _p127._1;
		var _p128 = _p127._0;
		if (_p128.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(_p134);
		} else {
			var _p133 = _p128._1;
			var _p132 = _p128._0;
			var _p129 = _p132.meaning;
			if ((_p129.ctor === 'EmphasisToken') && (_p129._1.ctor === '_Tuple2')) {
				var _p131 = _p129._1._1;
				var _p130 = _p129._1._0;
				if (_elm_lang$core$Native_Utils.eq(_p130, _p131)) {
					if ((!_elm_lang$core$Native_Utils.eq(_p131, 0)) && ((!_elm_lang$core$Native_Utils.eq(
						_p129._0,
						_elm_lang$core$Native_Utils.chr('_'))) || _elm_lang$core$Native_Utils.eq(_p131, 1))) {
						var _v68 = A2(
							_elm_lang$core$Maybe$withDefault,
							{
								ctor: '_Tuple2',
								_0: _p133,
								_1: A2(_user$project$Markdown_Inline$addToken, _p134, _p132)
							},
							A2(
								_elm_lang$core$Maybe$map,
								A3(_user$project$Markdown_Inline$emphasisToMatch, _p132, _p133, _p134),
								A2(
									_user$project$Markdown_Inline$findToken,
									_user$project$Markdown_Inline$isOpenEmphasisToken(_p132),
									_p134.tokens)));
						_p126 = _v68;
						continue emphasisTTM;
					} else {
						var _v69 = {ctor: '_Tuple2', _0: _p133, _1: _p134};
						_p126 = _v69;
						continue emphasisTTM;
					}
				} else {
					if (_elm_lang$core$Native_Utils.cmp(_p130, _p131) < 0) {
						var _v70 = {
							ctor: '_Tuple2',
							_0: _p133,
							_1: A2(_user$project$Markdown_Inline$addToken, _p134, _p132)
						};
						_p126 = _v70;
						continue emphasisTTM;
					} else {
						var _v71 = A2(
							_elm_lang$core$Maybe$withDefault,
							{ctor: '_Tuple2', _0: _p133, _1: _p134},
							A2(
								_elm_lang$core$Maybe$map,
								A3(_user$project$Markdown_Inline$emphasisToMatch, _p132, _p133, _p134),
								A2(
									_user$project$Markdown_Inline$findToken,
									_user$project$Markdown_Inline$isOpenEmphasisToken(_p132),
									_p134.tokens)));
						_p126 = _v71;
						continue emphasisTTM;
					}
				}
			} else {
				var _v72 = {
					ctor: '_Tuple2',
					_0: _p133,
					_1: A2(_user$project$Markdown_Inline$addToken, _p134, _p132)
				};
				_p126 = _v72;
				continue emphasisTTM;
			}
		}
	}
};
var _user$project$Markdown_Inline$emphasisToMatch = F4(
	function (closeToken, tokensTail, model, _p135) {
		var _p136 = _p135;
		var _p139 = _p136._2;
		var _p138 = _p136._0;
		var remainLength = _p138.length - closeToken.length;
		var _p137 = _elm_lang$core$Native_Utils.eq(remainLength, 0) ? {ctor: '_Tuple4', _0: _p138, _1: closeToken, _2: _p139, _3: tokensTail} : ((_elm_lang$core$Native_Utils.cmp(remainLength, 0) > 0) ? {
			ctor: '_Tuple4',
			_0: _elm_lang$core$Native_Utils.update(
				_p138,
				{index: _p138.index + remainLength, length: closeToken.length}),
			_1: closeToken,
			_2: {
				ctor: '::',
				_0: _elm_lang$core$Native_Utils.update(
					_p138,
					{length: remainLength}),
				_1: _p139
			},
			_3: tokensTail
		} : {
			ctor: '_Tuple4',
			_0: _p138,
			_1: _elm_lang$core$Native_Utils.update(
				closeToken,
				{length: _p138.length}),
			_2: _p139,
			_3: {
				ctor: '::',
				_0: _elm_lang$core$Native_Utils.update(
					closeToken,
					{index: closeToken.index + _p138.length, length: 0 - remainLength}),
				_1: tokensTail
			}
		});
		var updtOpenToken = _p137._0;
		var updtCloseToken = _p137._1;
		var updtRemainTokens = _p137._2;
		var updtTokensTail = _p137._3;
		var match = A6(
			_user$project$Markdown_Inline$tokenPairToMatch,
			model,
			function (s) {
				return s;
			},
			_user$project$Markdown_Inline$Emphasis(updtOpenToken.length),
			updtOpenToken,
			updtCloseToken,
			_elm_lang$core$List$reverse(_p136._1));
		return {
			ctor: '_Tuple2',
			_0: updtTokensTail,
			_1: _elm_lang$core$Native_Utils.update(
				model,
				{
					matches: {ctor: '::', _0: match, _1: model.matches},
					tokens: updtRemainTokens
				})
		};
	});
var _user$project$Markdown_Inline$htmlElementTTM = function (_p140) {
	htmlElementTTM:
	while (true) {
		var _p141 = _p140;
		var _p147 = _p141._1;
		var _p142 = _p141._0;
		if (_p142.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(_p147);
		} else {
			var _p146 = _p142._1;
			var _p145 = _p142._0;
			var _p143 = _p145.meaning;
			if (_p143.ctor === 'HtmlToken') {
				var _p144 = _p143._1;
				if (_user$project$Markdown_Inline$isVoidTag(_p144) || (!_p143._0)) {
					var _v77 = A2(
						F2(
							function (v0, v1) {
								return {ctor: '_Tuple2', _0: v0, _1: v1};
							}),
						_p146,
						A2(
							_user$project$Markdown_Inline$addMatch,
							_p147,
							A2(
								_user$project$Markdown_Inline$tokenToMatch,
								_p145,
								_user$project$Markdown_Inline$Html(_p144))));
					_p140 = _v77;
					continue htmlElementTTM;
				} else {
					var _v78 = A2(
						_elm_lang$core$Maybe$withDefault,
						A2(
							F2(
								function (v0, v1) {
									return {ctor: '_Tuple2', _0: v0, _1: v1};
								}),
							_p146,
							A2(
								_user$project$Markdown_Inline$addMatch,
								_p147,
								A2(
									_user$project$Markdown_Inline$tokenToMatch,
									_p145,
									_user$project$Markdown_Inline$Html(_p144)))),
						A2(
							_elm_lang$core$Maybe$map,
							A3(_user$project$Markdown_Inline$htmlElementToMatch, _p145, _p147, _p144),
							A2(
								_user$project$Markdown_Inline$findToken,
								_user$project$Markdown_Inline$isCloseToken(_p144),
								_p146)));
					_p140 = _v78;
					continue htmlElementTTM;
				}
			} else {
				var _v79 = {
					ctor: '_Tuple2',
					_0: _p146,
					_1: A2(_user$project$Markdown_Inline$addToken, _p147, _p145)
				};
				_p140 = _v79;
				continue htmlElementTTM;
			}
		}
	}
};
var _user$project$Markdown_Inline$htmlElementToMatch = F4(
	function (openToken, model, htmlModel, _p148) {
		var _p149 = _p148;
		return {
			ctor: '_Tuple2',
			_0: _p149._2,
			_1: _elm_lang$core$Native_Utils.update(
				model,
				{
					matches: {
						ctor: '::',
						_0: A6(
							_user$project$Markdown_Inline$tokenPairToMatch,
							model,
							function (s) {
								return s;
							},
							_user$project$Markdown_Inline$Html(htmlModel),
							openToken,
							_p149._0,
							_p149._1),
						_1: model.matches
					}
				})
		};
	});
var _user$project$Markdown_Inline$linkImageTTM = function (_p150) {
	linkImageTTM:
	while (true) {
		var _p151 = _p150;
		var _p156 = _p151._1;
		var _p152 = _p151._0;
		if (_p152.ctor === '[]') {
			return _user$project$Markdown_Inline$reverseTokens(_p156);
		} else {
			var _p155 = _p152._1;
			var _p154 = _p152._0;
			var _p153 = _p154.meaning;
			if ((_p153.ctor === 'CharToken') && (_p153._0.valueOf() === ']')) {
				var _v84 = A2(
					_elm_lang$core$Maybe$withDefault,
					{ctor: '_Tuple2', _0: _p155, _1: _p156},
					A2(
						_elm_lang$core$Maybe$andThen,
						A3(_user$project$Markdown_Inline$linkOrImageToMatch, _p154, _p155, _p156),
						A2(_user$project$Markdown_Inline$findToken, _user$project$Markdown_Inline$isLinkOrImageOpenToken, _p156.tokens)));
				_p150 = _v84;
				continue linkImageTTM;
			} else {
				var _v85 = {
					ctor: '_Tuple2',
					_0: _p155,
					_1: A2(_user$project$Markdown_Inline$addToken, _p156, _p154)
				};
				_p150 = _v85;
				continue linkImageTTM;
			}
		}
	}
};
var _user$project$Markdown_Inline$linkOrImageToMatch = F4(
	function (closeToken, tokensTail, model, _p157) {
		var _p158 = _p157;
		var _p163 = _p158._2;
		var _p162 = _p158._0;
		var _p161 = _p158._1;
		var linkOpenTokenToInactive = function (model_) {
			var process = function (token) {
				var _p159 = token.meaning;
				if (_p159.ctor === 'LinkOpenToken') {
					return _elm_lang$core$Native_Utils.update(
						token,
						{
							meaning: _user$project$Markdown_Inline$LinkOpenToken(false)
						});
				} else {
					return token;
				}
			};
			return _elm_lang$core$Native_Utils.update(
				model_,
				{
					tokens: A2(_elm_lang$core$List$map, process, model_.tokens)
				});
		};
		var removeOpenToken = _elm_lang$core$Maybe$Just(
			{
				ctor: '_Tuple2',
				_0: tokensTail,
				_1: _elm_lang$core$Native_Utils.update(
					model,
					{
						tokens: A2(_elm_lang$core$Basics_ops['++'], _p161, _p163)
					})
			});
		var tempMatch = function (isLink) {
			return A6(
				_user$project$Markdown_Inline$tokenPairToMatch,
				model,
				function (s) {
					return s;
				},
				isLink ? _user$project$Markdown_Inline$Link(
					{ctor: '_Tuple2', _0: '', _1: _elm_lang$core$Maybe$Nothing}) : _user$project$Markdown_Inline$Image(
					{ctor: '_Tuple2', _0: '', _1: _elm_lang$core$Maybe$Nothing}),
				_p162,
				closeToken,
				_elm_lang$core$List$reverse(_p161));
		};
		var remainText = A2(_elm_lang$core$String$dropLeft, closeToken.index + 1, model.rawText);
		var args = function (isLink) {
			return {
				ctor: '_Tuple3',
				_0: remainText,
				_1: tempMatch(isLink),
				_2: _elm_lang$core$Native_Utils.update(
					model,
					{tokens: _p163})
			};
		};
		var _p160 = _p162.meaning;
		switch (_p160.ctor) {
			case 'ImageOpenToken':
				return A2(
					_user$project$Markdown_Inline$ifNothing,
					removeOpenToken,
					A2(
						_elm_lang$core$Maybe$map,
						_user$project$Markdown_Inline$removeParsedAheadTokens(tokensTail),
						A2(
							_elm_lang$core$Maybe$andThen,
							_user$project$Markdown_Inline$checkParsedAheadOverlapping,
							A2(
								_user$project$Markdown_Inline$ifNothing,
								_user$project$Markdown_Inline$checkForRefLinkOrImage(
									args(false)),
								_user$project$Markdown_Inline$checkForInlineLinkOrImage(
									args(false))))));
			case 'LinkOpenToken':
				if (_p160._0 === true) {
					return A2(
						_user$project$Markdown_Inline$ifNothing,
						removeOpenToken,
						A2(
							_elm_lang$core$Maybe$map,
							_user$project$Markdown_Inline$removeParsedAheadTokens(tokensTail),
							A2(
								_elm_lang$core$Maybe$map,
								linkOpenTokenToInactive,
								A2(
									_elm_lang$core$Maybe$andThen,
									_user$project$Markdown_Inline$checkParsedAheadOverlapping,
									A2(
										_user$project$Markdown_Inline$ifNothing,
										_user$project$Markdown_Inline$checkForRefLinkOrImage(
											args(true)),
										_user$project$Markdown_Inline$checkForInlineLinkOrImage(
											args(true)))))));
				} else {
					return removeOpenToken;
				}
			default:
				return _elm_lang$core$Maybe$Nothing;
		}
	});
var _user$project$Markdown_Inline$parse = F3(
	function (options, refs, rawText) {
		return function (_) {
			return _.matches;
		}(
			_user$project$Markdown_Inline$parseText(
				_user$project$Markdown_Inline$organizeParserMatches(
					_user$project$Markdown_Inline$tokensToMatches(
						_user$project$Markdown_Inline$tokenize(
							A3(
								_user$project$Markdown_Inline$initParser,
								options,
								refs,
								_elm_lang$core$String$trim(rawText)))))));
	});
var _user$project$Markdown_Inline$EmphasisTag = function (a) {
	return {ctor: 'EmphasisTag', _0: a};
};

var _user$project$Markdown$blockToHtml = F4(
	function (options, elements, textAsParagraph, block) {
		var _p0 = block;
		switch (_p0.ctor) {
			case 'Heading':
				return {
					ctor: '::',
					_0: A2(
						elements.heading,
						_p0._0.level,
						A2(_user$project$Markdown_Inline$toHtml, elements, _p0._0.inlines)),
					_1: {ctor: '[]'}
				};
			case 'ThematicBreak':
				return {
					ctor: '::',
					_0: elements.thematicBreak,
					_1: {ctor: '[]'}
				};
			case 'Paragraph':
				return A2(
					elements.paragraph,
					textAsParagraph,
					A2(_user$project$Markdown_Inline$toHtml, elements, _p0._0.inlines));
			case 'Code':
				return {
					ctor: '::',
					_0: elements.code(_p0._0),
					_1: {ctor: '[]'}
				};
			case 'BlockQuote':
				return A3(
					_elm_lang$core$Basics$flip,
					F2(
						function (x, y) {
							return {ctor: '::', _0: x, _1: y};
						}),
					{ctor: '[]'},
					elements.blockQuote(
						A4(_user$project$Markdown$blocksToHtml, options, elements, true, _p0._0.blocks)));
			case 'List':
				return function (list) {
					return {
						ctor: '::',
						_0: list,
						_1: {ctor: '[]'}
					};
				}(
					A2(
						elements.list,
						_p0._0.type_,
						A2(
							_elm_lang$core$List$map,
							function (_p1) {
								return A2(
									_elm_lang$html$Html$li,
									{ctor: '[]'},
									A4(_user$project$Markdown$blocksToHtml, options, elements, _p0._0.isLoose, _p1));
							},
							_p0._0.items)));
			default:
				return A2(_user$project$Markdown_Inline$toHtml, elements, _p0._0.inlines);
		}
	});
var _user$project$Markdown$blocksToHtml = F3(
	function (options, elements, textAsParagraph) {
		return function (_p2) {
			return _elm_lang$core$List$concat(
				A2(
					_elm_lang$core$List$map,
					A3(_user$project$Markdown$blockToHtml, options, elements, textAsParagraph),
					_p2));
		};
	});
var _user$project$Markdown$insertLinkMatch = F2(
	function (refs, linkMatch) {
		return A2(_elm_lang$core$Dict$member, linkMatch.inside, refs) ? refs : A3(
			_elm_lang$core$Dict$insert,
			linkMatch.inside,
			{ctor: '_Tuple2', _0: linkMatch.url, _1: linkMatch.maybeTitle},
			refs);
	});
var _user$project$Markdown$hrefRegex = '\\s*(?:<([^<>\\s]*)>|([^\\s]*))';
var _user$project$Markdown$refRegex = _elm_lang$core$Regex$regex(
	A2(
		_elm_lang$core$Basics_ops['++'],
		'^\\s*\\[(',
		A2(
			_elm_lang$core$Basics_ops['++'],
			_user$project$Markdown_Inline$insideSquareBracketRegex,
			A2(
				_elm_lang$core$Basics_ops['++'],
				')\\]:',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_user$project$Markdown$hrefRegex,
					A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown_Inline$titleRegex, '\\s*(?![^\\n])'))))));
var _user$project$Markdown$extractUrlTitleRegex = function (regexMatch) {
	var _p3 = regexMatch.submatches;
	if (((((((_p3.ctor === '::') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === '::')) && (_p3._1._1.ctor === '::')) && (_p3._1._1._1.ctor === '::')) && (_p3._1._1._1._1.ctor === '::')) && (_p3._1._1._1._1._1.ctor === '::')) {
		var toReturn = function (rawUrl) {
			return {
				matchLength: _elm_lang$core$String$length(regexMatch.match),
				inside: _p3._0._0,
				url: rawUrl,
				maybeTitle: _user$project$Markdown_Inline$returnFirstJust(
					{
						ctor: '::',
						_0: _p3._1._1._1._0,
						_1: {
							ctor: '::',
							_0: _p3._1._1._1._1._0,
							_1: {
								ctor: '::',
								_0: _p3._1._1._1._1._1._0,
								_1: {ctor: '[]'}
							}
						}
					})
			};
		};
		var maybeRawUrl = _user$project$Markdown_Inline$returnFirstJust(
			{
				ctor: '::',
				_0: _p3._1._0,
				_1: {
					ctor: '::',
					_0: _p3._1._1._0,
					_1: {ctor: '[]'}
				}
			});
		return A2(_elm_lang$core$Maybe$map, toReturn, maybeRawUrl);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _user$project$Markdown$maybeLinkMatch = function (rawText) {
	return A2(
		_elm_lang$core$Maybe$andThen,
		function (linkMatch) {
			return (_elm_lang$core$Native_Utils.eq(linkMatch.url, '') || _elm_lang$core$Native_Utils.eq(linkMatch.inside, '')) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(linkMatch);
		},
		A2(
			_elm_lang$core$Maybe$map,
			function (linkMatch) {
				return _elm_lang$core$Native_Utils.update(
					linkMatch,
					{
						inside: _user$project$Markdown_Inline$prepareRefLabel(linkMatch.inside)
					});
			},
			A2(
				_elm_lang$core$Maybe$andThen,
				_user$project$Markdown$extractUrlTitleRegex,
				_elm_lang$core$List$head(
					A3(
						_elm_lang$core$Regex$find,
						_elm_lang$core$Regex$AtMost(1),
						_user$project$Markdown$refRegex,
						rawText)))));
};
var _user$project$Markdown$formatParagraphLine = function (rawParagraph) {
	return _elm_lang$core$Native_Utils.eq(
		A2(_elm_lang$core$String$right, 2, rawParagraph),
		'  ') ? A2(
		_elm_lang$core$Basics_ops['++'],
		_elm_lang$core$String$trim(rawParagraph),
		'  ') : _elm_lang$core$String$trim(rawParagraph);
};
var _user$project$Markdown$isBlankASLast = function (absSynsList) {
	isBlankASLast:
	while (true) {
		var _p4 = absSynsList;
		if (_p4.ctor === '::') {
			var _p5 = _p4._0;
			_v3_3:
			do {
				if (_p5.ctor === '::') {
					switch (_p5._0.ctor) {
						case 'BlankAS':
							if (_p5._1.ctor === '[]') {
								return false;
							} else {
								return true;
							}
						case 'ListAS':
							var _v4 = _p5._0._1;
							absSynsList = _v4;
							continue isBlankASLast;
						default:
							break _v3_3;
					}
				} else {
					break _v3_3;
				}
			} while(false);
			return false;
		} else {
			return false;
		}
	}
};
var _user$project$Markdown$initListASModel = {type_: _user$project$Markdown_Config$Unordered, indentLength: 2, delimiter: '-', isLoose: false};
var _user$project$Markdown$newListLine = F5(
	function (type_, indentString, delimiter, indentSpace, rawLine) {
		var indentSpaceLenth = _elm_lang$core$String$length(indentSpace);
		var isIndentedCode = _elm_lang$core$Native_Utils.cmp(indentSpaceLenth, 4) > -1;
		var indentLength = isIndentedCode ? ((1 + _elm_lang$core$String$length(indentString)) - _elm_lang$core$String$length(indentSpace)) : (1 + _elm_lang$core$String$length(indentString));
		var rawLine_ = isIndentedCode ? A2(_elm_lang$core$Basics_ops['++'], indentSpace, rawLine) : rawLine;
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$Native_Utils.update(
				_user$project$Markdown$initListASModel,
				{type_: type_, delimiter: delimiter, indentLength: indentLength}),
			_1: rawLine_
		};
	});
var _user$project$Markdown$codeASToBlock = function (model) {
	var _p6 = model;
	if (_p6.ctor === 'Indented') {
		return {language: _elm_lang$core$Maybe$Nothing, code: _p6._0._1};
	} else {
		var _p8 = _p6._0._1.language;
		var _p7 = _p6._0._2;
		return (_elm_lang$core$Native_Utils.cmp(
			_elm_lang$core$String$length(_p8),
			0) > 0) ? {
			language: _elm_lang$core$Maybe$Just(_p8),
			code: _p7
		} : {language: _elm_lang$core$Maybe$Nothing, code: _p7};
	}
};
var _user$project$Markdown$indentLine = function (indentLength) {
	return function (_p9) {
		return A4(
			_elm_lang$core$Regex$replace,
			_elm_lang$core$Regex$AtMost(1),
			_elm_lang$core$Regex$regex(
				A2(
					_elm_lang$core$Basics_ops['++'],
					'^ {0,',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(indentLength),
						'}'))),
			function (_p10) {
				return '';
			},
			A4(
				_elm_lang$core$Regex$replace,
				_elm_lang$core$Regex$All,
				_elm_lang$core$Regex$regex('\\t'),
				function (_p11) {
					return '    ';
				},
				_p9));
	};
};
var _user$project$Markdown$unorderedListMatch = function (match) {
	var _p12 = match.submatches;
	if ((((((((_p12.ctor === '::') && (_p12._0.ctor === 'Just')) && (_p12._1.ctor === '::')) && (_p12._1._0.ctor === 'Just')) && (_p12._1._1.ctor === '::')) && (_p12._1._1._0.ctor === 'Just')) && (_p12._1._1._1.ctor === '::')) && (_p12._1._1._1._1.ctor === '[]')) {
		return A5(
			_user$project$Markdown$newListLine,
			_user$project$Markdown_Config$Unordered,
			_p12._0._0,
			_p12._1._0._0,
			_p12._1._1._0._0,
			A2(_elm_lang$core$Maybe$withDefault, '', _p12._1._1._1._0));
	} else {
		return {ctor: '_Tuple2', _0: _user$project$Markdown$initListASModel, _1: ''};
	}
};
var _user$project$Markdown$orderedListMatch = function (match) {
	var _p13 = match.submatches;
	if (((((((((_p13.ctor === '::') && (_p13._0.ctor === 'Just')) && (_p13._1.ctor === '::')) && (_p13._1._0.ctor === 'Just')) && (_p13._1._1.ctor === '::')) && (_p13._1._1._0.ctor === 'Just')) && (_p13._1._1._1.ctor === '::')) && (_p13._1._1._1._0.ctor === 'Just')) && (_p13._1._1._1._1.ctor === '::')) {
		var type_ = A2(
			_elm_lang$core$Result$withDefault,
			_user$project$Markdown_Config$Unordered,
			A2(
				_elm_lang$core$Result$map,
				_user$project$Markdown_Config$Ordered,
				_elm_lang$core$String$toInt(_p13._1._0._0)));
		return A5(
			_user$project$Markdown$newListLine,
			type_,
			_p13._0._0,
			_p13._1._1._0._0,
			_p13._1._1._1._0._0,
			A2(_elm_lang$core$Maybe$withDefault, '', _p13._1._1._1._1._0));
	} else {
		return {ctor: '_Tuple2', _0: _user$project$Markdown$initListASModel, _1: ''};
	}
};
var _user$project$Markdown$listMatch = F2(
	function (type_, match) {
		var _p14 = type_;
		if (_p14.ctor === 'Unordered') {
			return _user$project$Markdown$unorderedListMatch(match);
		} else {
			return _user$project$Markdown$orderedListMatch(match);
		}
	});
var _user$project$Markdown$indentedCodeMatch = function (_p15) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		{
			ctor: '_Tuple2',
			_0: {ctor: '[]'},
			_1: ''
		},
		A2(
			_elm_lang$core$Maybe$map,
			F2(
				function (v0, v1) {
					return {ctor: '_Tuple2', _0: v0, _1: v1};
				})(
				{ctor: '[]'}),
			A2(
				_elm_lang$core$Maybe$withDefault,
				_elm_lang$core$Maybe$Nothing,
				_elm_lang$core$List$head(
					function (_) {
						return _.submatches;
					}(_p15)))));
};
var _user$project$Markdown$blockQuoteMatch = function (match) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		'',
		A2(
			_elm_lang$core$Maybe$withDefault,
			_elm_lang$core$Maybe$Nothing,
			_elm_lang$core$List$head(match.submatches)));
};
var _user$project$Markdown$headingSetextMatch = function (match) {
	var _p16 = match.submatches;
	if ((_p16.ctor === '::') && (_p16._0.ctor === 'Just')) {
		var _p17 = _p16._0._0;
		return A2(_elm_lang$core$String$startsWith, '=', _p17) ? {ctor: '_Tuple2', _0: 1, _1: _p17} : {ctor: '_Tuple2', _0: 2, _1: _p17};
	} else {
		return {ctor: '_Tuple2', _0: 1, _1: ''};
	}
};
var _user$project$Markdown$headingAtxMatch = function (match) {
	var _p18 = match.submatches;
	if ((((_p18.ctor === '::') && (_p18._0.ctor === 'Just')) && (_p18._1.ctor === '::')) && (_p18._1._0.ctor === 'Just')) {
		return {
			ctor: '_Tuple2',
			_0: _elm_lang$core$String$length(_p18._0._0),
			_1: _p18._1._0._0
		};
	} else {
		return {ctor: '_Tuple2', _0: 1, _1: match.match};
	}
};
var _user$project$Markdown$initSpacesRegex = _elm_lang$core$Regex$regex('^ +');
var _user$project$Markdown$indentLength = function (_p19) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		0,
		A2(
			_elm_lang$core$Maybe$map,
			function (_p20) {
				return _elm_lang$core$String$length(
					function (_) {
						return _.match;
					}(_p20));
			},
			_elm_lang$core$List$head(
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_user$project$Markdown$initSpacesRegex,
					A4(
						_elm_lang$core$Regex$replace,
						_elm_lang$core$Regex$All,
						_elm_lang$core$Regex$regex('\\t'),
						function (_p21) {
							return '    ';
						},
						_p19)))));
};
var _user$project$Markdown$unorderedListRegex = _elm_lang$core$Regex$regex('^( *([\\*\\-\\+])( {0,4}))(?:[ \\t](.*))?$');
var _user$project$Markdown$orderedListRegex = _elm_lang$core$Regex$regex('^( *(\\d{1,9})([.)])( {0,4}))(?:[ \\t](.*))?$');
var _user$project$Markdown$closingFenceCodeLineRegex = _elm_lang$core$Regex$regex('^ {0,3}(`{3,}|~{3,})\\s*$');
var _user$project$Markdown$isClosingFenceLine = function (fence) {
	return function (_p22) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			false,
			A2(
				_elm_lang$core$Maybe$map,
				function (match) {
					var _p23 = match.submatches;
					if ((_p23.ctor === '::') && (_p23._0.ctor === 'Just')) {
						var _p24 = _p23._0._0;
						return (_elm_lang$core$Native_Utils.cmp(
							_elm_lang$core$String$length(_p24),
							fence.fenceLength) > -1) && _elm_lang$core$Native_Utils.eq(
							A2(_elm_lang$core$String$left, 1, _p24),
							fence.fenceChar);
					} else {
						return false;
					}
				},
				_elm_lang$core$List$head(
					A3(
						_elm_lang$core$Regex$find,
						_elm_lang$core$Regex$AtMost(1),
						_user$project$Markdown$closingFenceCodeLineRegex,
						_p22))));
	};
};
var _user$project$Markdown$openingFenceCodeLineRegex = _elm_lang$core$Regex$regex('^( {0,3})(`{3,}(?!.*`)|~{3,}(?!.*~))(.*)$');
var _user$project$Markdown$indentedCodeLineRegex = _elm_lang$core$Regex$regex('^(?: {4,4}| {0,3}\\t)(.*)$');
var _user$project$Markdown$blockQuoteLineRegex = _elm_lang$core$Regex$regex('^ {0,3}(?:>[ ]?)(.*)$');
var _user$project$Markdown$thematicBreakLineRegex = _elm_lang$core$Regex$regex('^ {0,3}(?:(?:\\*[ \\t]*){3,}|(?:_[ \\t]*){3,}|(?:-[ \\t]*){3,})[ \\t]*$');
var _user$project$Markdown$headingSetextLineRegex = _elm_lang$core$Regex$regex('^ {0,3}(=+|-+)[ \\t]*$');
var _user$project$Markdown$headingAtxLineRegex = _elm_lang$core$Regex$regex('^ {0,3}(#{1,6})(?:[ \\t]+[ \\t#]+$|[ \\t]+|$)(.*?)(?:\\s+[ \\t#]*)?$');
var _user$project$Markdown$blankLineRegex = _elm_lang$core$Regex$regex('^\\s*$');
var _user$project$Markdown$dropRefString = F2(
	function (rawText, inlineMatch) {
		var strippedText = A2(_elm_lang$core$String$dropLeft, inlineMatch.matchLength, rawText);
		return A2(_elm_lang$core$Regex$contains, _user$project$Markdown$blankLineRegex, strippedText) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(strippedText);
	});
var _user$project$Markdown$parseReference = F2(
	function (refs, rawText) {
		parseReference:
		while (true) {
			var _p25 = _user$project$Markdown$maybeLinkMatch(rawText);
			if (_p25.ctor === 'Just') {
				var _p27 = _p25._0;
				var updtRefs = A2(_user$project$Markdown$insertLinkMatch, refs, _p27);
				var maybeStrippedText = A2(_user$project$Markdown$dropRefString, rawText, _p27);
				var _p26 = maybeStrippedText;
				if (_p26.ctor === 'Just') {
					var _v14 = updtRefs,
						_v15 = _p26._0;
					refs = _v14;
					rawText = _v15;
					continue parseReference;
				} else {
					return {ctor: '_Tuple2', _0: updtRefs, _1: _elm_lang$core$Maybe$Nothing};
				}
			} else {
				return {
					ctor: '_Tuple2',
					_0: refs,
					_1: _elm_lang$core$Maybe$Just(rawText)
				};
			}
		}
	});
var _user$project$Markdown$toRawLines = _elm_lang$core$String$lines;
var _user$project$Markdown$FenceModel = F4(
	function (a, b, c, d) {
		return {indentLength: a, fenceLength: b, fenceChar: c, language: d};
	});
var _user$project$Markdown$openingFenceCodeMatch = function (match) {
	var _p28 = match.submatches;
	if ((((((_p28.ctor === '::') && (_p28._0.ctor === 'Just')) && (_p28._1.ctor === '::')) && (_p28._1._0.ctor === 'Just')) && (_p28._1._1.ctor === '::')) && (_p28._1._1._0.ctor === 'Just')) {
		var _p29 = _p28._1._0._0;
		return {
			ctor: '_Tuple3',
			_0: true,
			_1: {
				indentLength: _elm_lang$core$String$length(_p28._0._0),
				fenceLength: _elm_lang$core$String$length(_p29),
				fenceChar: A2(_elm_lang$core$String$left, 1, _p29),
				language: A2(
					_elm_lang$core$Maybe$withDefault,
					'',
					A2(
						_elm_lang$core$Maybe$map,
						_user$project$Markdown_Inline$replaceEscapable,
						_elm_lang$core$List$head(
							_elm_lang$core$String$words(_p28._1._1._0._0))))
			},
			_2: ''
		};
	} else {
		return {
			ctor: '_Tuple3',
			_0: true,
			_1: A4(_user$project$Markdown$FenceModel, 0, 0, '`', ''),
			_2: ''
		};
	}
};
var _user$project$Markdown$ListASModel = F4(
	function (a, b, c, d) {
		return {type_: a, indentLength: b, delimiter: c, isLoose: d};
	});
var _user$project$Markdown$LinkMatch = F4(
	function (a, b, c, d) {
		return {matchLength: a, inside: b, url: c, maybeTitle: d};
	});
var _user$project$Markdown$HeadingBlock = F2(
	function (a, b) {
		return {level: a, inlines: b};
	});
var _user$project$Markdown$ParagraphBlock = function (a) {
	return {inlines: a};
};
var _user$project$Markdown$BlockQuoteBlock = function (a) {
	return {blocks: a};
};
var _user$project$Markdown$ListBlock = F3(
	function (a, b, c) {
		return {type_: a, isLoose: b, items: c};
	});
var _user$project$Markdown$HtmlBlock = function (a) {
	return {inlines: a};
};
var _user$project$Markdown$UnorderedListLine = {ctor: 'UnorderedListLine'};
var _user$project$Markdown$OrderedListLine = {ctor: 'OrderedListLine'};
var _user$project$Markdown$BlockQuoteLine = {ctor: 'BlockQuoteLine'};
var _user$project$Markdown$OpeningFenceCodeLine = {ctor: 'OpeningFenceCodeLine'};
var _user$project$Markdown$IndentedCodeLine = {ctor: 'IndentedCodeLine'};
var _user$project$Markdown$ThematicBreakLine = {ctor: 'ThematicBreakLine'};
var _user$project$Markdown$listLineRegexes = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: _user$project$Markdown$ThematicBreakLine, _1: _user$project$Markdown$thematicBreakLineRegex},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: _user$project$Markdown$OrderedListLine, _1: _user$project$Markdown$orderedListRegex},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _user$project$Markdown$UnorderedListLine, _1: _user$project$Markdown$unorderedListRegex},
			_1: {ctor: '[]'}
		}
	}
};
var _user$project$Markdown$SetextHeadingLine = {ctor: 'SetextHeadingLine'};
var _user$project$Markdown$ATXHeadingLine = {ctor: 'ATXHeadingLine'};
var _user$project$Markdown$BlankLine = {ctor: 'BlankLine'};
var _user$project$Markdown$lineMinusListRegexes = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: _user$project$Markdown$BlankLine, _1: _user$project$Markdown$blankLineRegex},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: _user$project$Markdown$IndentedCodeLine, _1: _user$project$Markdown$indentedCodeLineRegex},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _user$project$Markdown$OpeningFenceCodeLine, _1: _user$project$Markdown$openingFenceCodeLineRegex},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: _user$project$Markdown$SetextHeadingLine, _1: _user$project$Markdown$headingSetextLineRegex},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: _user$project$Markdown$ATXHeadingLine, _1: _user$project$Markdown$headingAtxLineRegex},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: _user$project$Markdown$BlockQuoteLine, _1: _user$project$Markdown$blockQuoteLineRegex},
						_1: {ctor: '[]'}
					}
				}
			}
		}
	}
};
var _user$project$Markdown$lineRegexes = A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown$lineMinusListRegexes, _user$project$Markdown$listLineRegexes);
var _user$project$Markdown$listLineFirstRegexes = A2(_elm_lang$core$Basics_ops['++'], _user$project$Markdown$listLineRegexes, _user$project$Markdown$lineMinusListRegexes);
var _user$project$Markdown$ParagraphAS = function (a) {
	return {ctor: 'ParagraphAS', _0: a};
};
var _user$project$Markdown$addToParagraph = F2(
	function (paragraph, rawLine) {
		return _user$project$Markdown$ParagraphAS(
			A2(
				_elm_lang$core$Basics_ops['++'],
				paragraph,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'\n',
					_user$project$Markdown$formatParagraphLine(rawLine))));
	});
var _user$project$Markdown$ListAS = F2(
	function (a, b) {
		return {ctor: 'ListAS', _0: a, _1: b};
	});
var _user$project$Markdown$BlockQuoteAS = function (a) {
	return {ctor: 'BlockQuoteAS', _0: a};
};
var _user$project$Markdown$maybeContinueParagraph = F2(
	function (rawLine, absSyns) {
		var _p30 = absSyns;
		_v17_3:
		do {
			if (_p30.ctor === '::') {
				switch (_p30._0.ctor) {
					case 'ParagraphAS':
						return _elm_lang$core$Maybe$Just(
							{
								ctor: '::',
								_0: A2(_user$project$Markdown$addToParagraph, _p30._0._0, rawLine),
								_1: _p30._1
							});
					case 'BlockQuoteAS':
						return A2(
							_elm_lang$core$Maybe$map,
							function (updtASs_) {
								return {
									ctor: '::',
									_0: _user$project$Markdown$BlockQuoteAS(updtASs_),
									_1: _p30._1
								};
							},
							A2(_user$project$Markdown$maybeContinueParagraph, rawLine, _p30._0._0));
					case 'ListAS':
						var _p31 = _p30._0._1;
						if (_p31.ctor === '::') {
							return A2(
								_elm_lang$core$Maybe$map,
								function (updtASs_) {
									return {
										ctor: '::',
										_0: A2(
											_user$project$Markdown$ListAS,
											_p30._0._0,
											{ctor: '::', _0: updtASs_, _1: _p31._1}),
										_1: _p30._1
									};
								},
								A2(_user$project$Markdown$maybeContinueParagraph, rawLine, _p31._0));
						} else {
							return _elm_lang$core$Maybe$Nothing;
						}
					default:
						break _v17_3;
				}
			} else {
				break _v17_3;
			}
		} while(false);
		return _elm_lang$core$Maybe$Nothing;
	});
var _user$project$Markdown$parseTextLine = F2(
	function (rawLine, absSyns) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			{
				ctor: '::',
				_0: _user$project$Markdown$ParagraphAS(
					_user$project$Markdown$formatParagraphLine(rawLine)),
				_1: absSyns
			},
			A2(_user$project$Markdown$maybeContinueParagraph, rawLine, absSyns));
	});
var _user$project$Markdown$parseReferences = function (refs) {
	var applyParser = F2(
		function (absSyn, _p32) {
			var _p33 = _p32;
			var _p41 = _p33._0;
			var _p40 = _p33._1;
			var _p34 = absSyn;
			switch (_p34.ctor) {
				case 'ParagraphAS':
					var _p35 = A2(_user$project$Markdown$parseReference, _elm_lang$core$Dict$empty, _p34._0);
					var paragraphRefs = _p35._0;
					var maybeUpdtText = _p35._1;
					var updtRefs = A2(_elm_lang$core$Dict$union, paragraphRefs, _p41);
					var _p36 = maybeUpdtText;
					if (_p36.ctor === 'Just') {
						return {
							ctor: '_Tuple2',
							_0: updtRefs,
							_1: {
								ctor: '::',
								_0: _user$project$Markdown$ParagraphAS(_p36._0),
								_1: _p40
							}
						};
					} else {
						return {ctor: '_Tuple2', _0: updtRefs, _1: _p40};
					}
				case 'ListAS':
					var _p37 = A3(
						_elm_lang$core$List$foldl,
						F2(
							function (absSyns, _p38) {
								var _p39 = _p38;
								return A2(
									_elm_lang$core$Tuple$mapSecond,
									A2(
										_elm_lang$core$Basics$flip,
										F2(
											function (x, y) {
												return {ctor: '::', _0: x, _1: y};
											}),
										_p39._1),
									A2(_user$project$Markdown$parseReferences, _p39._0, absSyns));
							}),
						{
							ctor: '_Tuple2',
							_0: _p41,
							_1: {ctor: '[]'}
						},
						_p34._1);
					var updtRefs = _p37._0;
					var updtAbsSynsList = _p37._1;
					return {
						ctor: '_Tuple2',
						_0: updtRefs,
						_1: {
							ctor: '::',
							_0: A2(_user$project$Markdown$ListAS, _p34._0, updtAbsSynsList),
							_1: _p40
						}
					};
				case 'BlockQuoteAS':
					return A2(
						_elm_lang$core$Tuple$mapSecond,
						A2(
							_elm_lang$core$Basics$flip,
							F2(
								function (x, y) {
									return {ctor: '::', _0: x, _1: y};
								}),
							_p40),
						A2(
							_elm_lang$core$Tuple$mapSecond,
							_user$project$Markdown$BlockQuoteAS,
							A2(_user$project$Markdown$parseReferences, _p41, _p34._0)));
				default:
					return {
						ctor: '_Tuple2',
						_0: _p41,
						_1: {ctor: '::', _0: absSyn, _1: _p40}
					};
			}
		});
	return A2(
		_elm_lang$core$List$foldl,
		applyParser,
		{
			ctor: '_Tuple2',
			_0: refs,
			_1: {ctor: '[]'}
		});
};
var _user$project$Markdown$CodeAS = function (a) {
	return {ctor: 'CodeAS', _0: a};
};
var _user$project$Markdown$ThematicBreakAS = {ctor: 'ThematicBreakAS'};
var _user$project$Markdown$HeadingAS = function (a) {
	return {ctor: 'HeadingAS', _0: a};
};
var _user$project$Markdown$BlankAS = {ctor: 'BlankAS'};
var _user$project$Markdown$Fenced = function (a) {
	return {ctor: 'Fenced', _0: a};
};
var _user$project$Markdown$parseFencedCodeLine = F2(
	function (match, absSyns) {
		return A3(
			_elm_lang$core$Basics$flip,
			F2(
				function (x, y) {
					return {ctor: '::', _0: x, _1: y};
				}),
			absSyns,
			_user$project$Markdown$CodeAS(
				_user$project$Markdown$Fenced(
					_user$project$Markdown$openingFenceCodeMatch(match))));
	});
var _user$project$Markdown$continueOrCloseFence = F3(
	function (fence, previousCode, rawLine) {
		return A2(_user$project$Markdown$isClosingFenceLine, fence, rawLine) ? _user$project$Markdown$Fenced(
			{ctor: '_Tuple3', _0: false, _1: fence, _2: previousCode}) : _user$project$Markdown$Fenced(
			{
				ctor: '_Tuple3',
				_0: true,
				_1: fence,
				_2: A2(
					_elm_lang$core$Basics_ops['++'],
					previousCode,
					A2(
						_elm_lang$core$Basics_ops['++'],
						A2(_user$project$Markdown$indentLine, fence.indentLength, rawLine),
						'\n'))
			});
	});
var _user$project$Markdown$Indented = function (a) {
	return {ctor: 'Indented', _0: a};
};
var _user$project$Markdown$parseBlankLine = F2(
	function (match, absSyns) {
		var _p42 = absSyns;
		_v23_3:
		do {
			if (_p42.ctor === '::') {
				switch (_p42._0.ctor) {
					case 'CodeAS':
						if (_p42._0._0.ctor === 'Indented') {
							if (_p42._0._0._0.ctor === '_Tuple2') {
								return function (b) {
									return {ctor: '::', _0: b, _1: _p42._1};
								}(
									_user$project$Markdown$CodeAS(
										_user$project$Markdown$Indented(
											{
												ctor: '_Tuple2',
												_0: {ctor: '::', _0: match.match, _1: _p42._0._0._0._0},
												_1: _p42._0._0._0._1
											})));
							} else {
								break _v23_3;
							}
						} else {
							if ((_p42._0._0._0.ctor === '_Tuple3') && (_p42._0._0._0._0 === true)) {
								return function (b) {
									return {ctor: '::', _0: b, _1: _p42._1};
								}(
									_user$project$Markdown$CodeAS(
										_user$project$Markdown$Fenced(
											{
												ctor: '_Tuple3',
												_0: true,
												_1: _p42._0._0._0._1,
												_2: A2(_elm_lang$core$Basics_ops['++'], _p42._0._0._0._2, '\n')
											})));
							} else {
								break _v23_3;
							}
						}
					case 'ListAS':
						return {
							ctor: '::',
							_0: A2(
								_user$project$Markdown$ListAS,
								_p42._0._0,
								A2(_user$project$Markdown$addBlankLineToASsList, match, _p42._0._1)),
							_1: _p42._1
						};
					default:
						break _v23_3;
				}
			} else {
				break _v23_3;
			}
		} while(false);
		return {ctor: '::', _0: _user$project$Markdown$BlankAS, _1: absSyns};
	});
var _user$project$Markdown$addBlankLineToASsList = F2(
	function (match, absSynsList) {
		var _p43 = absSynsList;
		if (_p43.ctor === '::') {
			return {
				ctor: '::',
				_0: A2(_user$project$Markdown$parseBlankLine, match, _p43._0),
				_1: _p43._1
			};
		} else {
			return {
				ctor: '::',
				_0: {
					ctor: '::',
					_0: _user$project$Markdown$BlankAS,
					_1: {ctor: '[]'}
				},
				_1: {ctor: '[]'}
			};
		}
	});
var _user$project$Markdown$appendIndentedCode = F2(
	function (_p45, _p44) {
		var _p46 = _p45;
		var _p47 = _p44;
		var indentBL = function (blankLine) {
			return A2(
				_elm_lang$core$Basics_ops['++'],
				A2(_user$project$Markdown$indentLine, 4, blankLine),
				'\n');
		};
		var blankLinesStr = _elm_lang$core$String$concat(
			A2(
				_elm_lang$core$List$map,
				indentBL,
				_elm_lang$core$List$reverse(_p47._0)));
		return _user$project$Markdown$Indented(
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: A2(
					_elm_lang$core$Basics_ops['++'],
					_p47._1,
					A2(
						_elm_lang$core$Basics_ops['++'],
						blankLinesStr,
						A2(_elm_lang$core$Basics_ops['++'], _p46._1, '\n')))
			});
	});
var _user$project$Markdown$parseIndentedCodeLine = F2(
	function (match, absSyns) {
		var _p48 = _user$project$Markdown$indentedCodeMatch(match);
		var blankLines = _p48._0;
		var codeLine = _p48._1;
		var _p49 = absSyns;
		if (((_p49.ctor === '::') && (_p49._0.ctor === 'CodeAS')) && (_p49._0._0.ctor === 'Indented')) {
			return {
				ctor: '::',
				_0: _user$project$Markdown$CodeAS(
					A2(
						_user$project$Markdown$appendIndentedCode,
						{ctor: '_Tuple2', _0: blankLines, _1: codeLine},
						_p49._0._0._0)),
				_1: _p49._1
			};
		} else {
			return A2(
				_elm_lang$core$Maybe$withDefault,
				{
					ctor: '::',
					_0: _user$project$Markdown$CodeAS(
						_user$project$Markdown$Indented(
							{
								ctor: '_Tuple2',
								_0: {ctor: '[]'},
								_1: A2(_elm_lang$core$Basics_ops['++'], codeLine, '\n')
							})),
					_1: absSyns
				},
				A2(_user$project$Markdown$maybeContinueParagraph, codeLine, absSyns));
		}
	});
var _user$project$Markdown$parseLine = F3(
	function (line, absSyns, match) {
		var _p50 = line;
		switch (_p50.ctor) {
			case 'BlankLine':
				return A2(_user$project$Markdown$parseBlankLine, match, absSyns);
			case 'ATXHeadingLine':
				return {
					ctor: '::',
					_0: _user$project$Markdown$HeadingAS(
						_user$project$Markdown$headingAtxMatch(match)),
					_1: absSyns
				};
			case 'SetextHeadingLine':
				return A2(_user$project$Markdown$parseSetextHeadingLine, match, absSyns);
			case 'ThematicBreakLine':
				return {ctor: '::', _0: _user$project$Markdown$ThematicBreakAS, _1: absSyns};
			case 'IndentedCodeLine':
				return A2(_user$project$Markdown$parseIndentedCodeLine, match, absSyns);
			case 'OpeningFenceCodeLine':
				return A2(_user$project$Markdown$parseFencedCodeLine, match, absSyns);
			case 'BlockQuoteLine':
				return A2(_user$project$Markdown$parseBlockQuoteLine, match, absSyns);
			case 'OrderedListLine':
				return A3(
					_user$project$Markdown$parseListLine,
					_user$project$Markdown_Config$Ordered(0),
					match,
					absSyns);
			default:
				return A3(_user$project$Markdown$parseListLine, _user$project$Markdown_Config$Unordered, match, absSyns);
		}
	});
var _user$project$Markdown$parseBlockQuoteLine = F2(
	function (match, absSyns) {
		var rawLine = _user$project$Markdown$blockQuoteMatch(match);
		var _p51 = absSyns;
		if ((_p51.ctor === '::') && (_p51._0.ctor === 'BlockQuoteAS')) {
			return {
				ctor: '::',
				_0: _user$project$Markdown$BlockQuoteAS(
					_user$project$Markdown$parseRawLines(
						{
							ctor: '_Tuple2',
							_0: {
								ctor: '::',
								_0: rawLine,
								_1: {ctor: '[]'}
							},
							_1: _p51._0._0
						})),
				_1: _p51._1
			};
		} else {
			return {
				ctor: '::',
				_0: _user$project$Markdown$BlockQuoteAS(
					_user$project$Markdown$parseRawLines(
						{
							ctor: '_Tuple2',
							_0: {
								ctor: '::',
								_0: rawLine,
								_1: {ctor: '[]'}
							},
							_1: {ctor: '[]'}
						})),
				_1: absSyns
			};
		}
	});
var _user$project$Markdown$parseRawLines = function (_p52) {
	parseRawLines:
	while (true) {
		var _p53 = _p52;
		var _p55 = _p53._1;
		var _p54 = _p53._0;
		if (_p54.ctor === '[]') {
			return _p55;
		} else {
			var _v32 = A2(
				F2(
					function (v0, v1) {
						return {ctor: '_Tuple2', _0: v0, _1: v1};
					}),
				_p54._1,
				_user$project$Markdown$preParseRawLine(
					{ctor: '_Tuple2', _0: _p54._0, _1: _p55}));
			_p52 = _v32;
			continue parseRawLines;
		}
	}
};
var _user$project$Markdown$preParseRawLine = function (_p56) {
	var _p57 = _p56;
	var _p65 = _p57._0;
	var _p64 = _p57._1;
	var _p58 = _p64;
	_v34_2:
	do {
		if (_p58.ctor === '::') {
			switch (_p58._0.ctor) {
				case 'ListAS':
					var _p63 = _p58._0._0;
					var _p62 = _p58._1;
					if (_elm_lang$core$Native_Utils.cmp(
						_user$project$Markdown$indentLength(_p65),
						_p63.indentLength) > -1) {
						var _p59 = _p58._0._1;
						if (_p59.ctor === '::') {
							var _p61 = _p59._0;
							var unindentedRawLine = A2(_user$project$Markdown$indentLine, _p63.indentLength, _p65);
							var updtListAS = function (model_) {
								return {
									ctor: '::',
									_0: A2(
										_user$project$Markdown$ListAS,
										model_,
										{
											ctor: '::',
											_0: _user$project$Markdown$parseRawLines(
												{
													ctor: '_Tuple2',
													_0: {
														ctor: '::',
														_0: unindentedRawLine,
														_1: {ctor: '[]'}
													},
													_1: _p61
												}),
											_1: _p59._1
										}),
									_1: _p62
								};
							};
							var _p60 = _p61;
							_v36_3:
							do {
								if (_p60.ctor === '::') {
									switch (_p60._0.ctor) {
										case 'BlankAS':
											if (_p60._1.ctor === '[]') {
												return updtListAS(_p63);
											} else {
												return A2(
													_elm_lang$core$List$all,
													F2(
														function (x, y) {
															return _elm_lang$core$Native_Utils.eq(x, y);
														})(_user$project$Markdown$BlankAS),
													_p60._1) ? A2(_user$project$Markdown$parseRawLine, _p65, _p64) : updtListAS(
													_elm_lang$core$Native_Utils.update(
														_p63,
														{isLoose: true}));
											}
										case 'ListAS':
											return (_elm_lang$core$Native_Utils.cmp(
												_user$project$Markdown$indentLength(unindentedRawLine),
												_p60._0._0.indentLength) > -1) ? updtListAS(_p63) : (_user$project$Markdown$isBlankASLast(_p60._0._1) ? updtListAS(
												_elm_lang$core$Native_Utils.update(
													_p63,
													{isLoose: true})) : updtListAS(_p63));
										default:
											break _v36_3;
									}
								} else {
									break _v36_3;
								}
							} while(false);
							return updtListAS(_p63);
						} else {
							return {
								ctor: '::',
								_0: A2(
									_user$project$Markdown$ListAS,
									_p63,
									{
										ctor: '::',
										_0: _user$project$Markdown$parseRawLines(
											{
												ctor: '_Tuple2',
												_0: {
													ctor: '::',
													_0: A2(_user$project$Markdown$indentLine, _p63.indentLength, _p65),
													_1: {ctor: '[]'}
												},
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}),
								_1: _p62
							};
						}
					} else {
						return A2(_user$project$Markdown$parseRawLineConfigFirst, _p65, _p64);
					}
				case 'CodeAS':
					if (((_p58._0._0.ctor === 'Fenced') && (_p58._0._0._0.ctor === '_Tuple3')) && (_p58._0._0._0._0 === true)) {
						return function (codeAS) {
							return {ctor: '::', _0: codeAS, _1: _p58._1};
						}(
							_user$project$Markdown$CodeAS(
								A3(_user$project$Markdown$continueOrCloseFence, _p58._0._0._0._1, _p58._0._0._0._2, _p65)));
					} else {
						break _v34_2;
					}
				default:
					break _v34_2;
			}
		} else {
			break _v34_2;
		}
	} while(false);
	return A2(_user$project$Markdown$parseRawLine, _p65, _p64);
};
var _user$project$Markdown$parseRawLine = F2(
	function (rawLine, absSyns) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			A2(_user$project$Markdown$parseTextLine, rawLine, absSyns),
			A3(
				_elm_lang$core$List$foldl,
				A2(_user$project$Markdown$applyRegex, rawLine, absSyns),
				_elm_lang$core$Maybe$Nothing,
				_user$project$Markdown$lineRegexes));
	});
var _user$project$Markdown$applyRegex = F4(
	function (rawLine, absSyns, _p66, maybeASs) {
		var _p67 = _p66;
		return _elm_lang$core$Native_Utils.eq(maybeASs, _elm_lang$core$Maybe$Nothing) ? A2(
			_elm_lang$core$Maybe$map,
			A2(_user$project$Markdown$parseLine, _p67._0, absSyns),
			_elm_lang$core$List$head(
				A3(
					_elm_lang$core$Regex$find,
					_elm_lang$core$Regex$AtMost(1),
					_p67._1,
					rawLine))) : maybeASs;
	});
var _user$project$Markdown$parseRawLineConfigFirst = F2(
	function (rawLine, absSyns) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			A2(_user$project$Markdown$parseTextLine, rawLine, absSyns),
			A3(
				_elm_lang$core$List$foldl,
				A2(_user$project$Markdown$applyRegex, rawLine, absSyns),
				_elm_lang$core$Maybe$Nothing,
				_user$project$Markdown$listLineFirstRegexes));
	});
var _user$project$Markdown$parseListLine = F3(
	function (type_, match, absSyns) {
		var _p68 = A2(_user$project$Markdown$listMatch, type_, match);
		var lineModel = _p68._0;
		var rawLine = _p68._1;
		var parsedRawLine = _user$project$Markdown$parseRawLines(
			{
				ctor: '_Tuple2',
				_0: {
					ctor: '::',
					_0: rawLine,
					_1: {ctor: '[]'}
				},
				_1: {ctor: '[]'}
			});
		var newListAS = {
			ctor: '::',
			_0: A2(
				_user$project$Markdown$ListAS,
				lineModel,
				{
					ctor: '::',
					_0: parsedRawLine,
					_1: {ctor: '[]'}
				}),
			_1: absSyns
		};
		var _p69 = absSyns;
		_v38_2:
		do {
			if (_p69.ctor === '::') {
				switch (_p69._0.ctor) {
					case 'ListAS':
						var _p71 = _p69._0._1;
						var _p70 = _p69._0._0;
						return _elm_lang$core$Native_Utils.eq(lineModel.delimiter, _p70.delimiter) ? {
							ctor: '::',
							_0: A2(
								_user$project$Markdown$ListAS,
								_elm_lang$core$Native_Utils.update(
									_p70,
									{
										indentLength: lineModel.indentLength,
										isLoose: _p70.isLoose || _user$project$Markdown$isBlankASLast(_p71)
									}),
								{ctor: '::', _0: parsedRawLine, _1: _p71}),
							_1: _p69._1
						} : newListAS;
					case 'ParagraphAS':
						var _p74 = _p69._0._0;
						var _p73 = _p69._1;
						if (_elm_lang$core$Native_Utils.eq(
							parsedRawLine,
							{
								ctor: '::',
								_0: _user$project$Markdown$BlankAS,
								_1: {ctor: '[]'}
							})) {
							return {
								ctor: '::',
								_0: A2(_user$project$Markdown$addToParagraph, _p74, match.match),
								_1: _p73
							};
						} else {
							var _p72 = lineModel.type_;
							if (_p72.ctor === 'Ordered') {
								if (_p72._0 === 1) {
									return newListAS;
								} else {
									return {
										ctor: '::',
										_0: A2(_user$project$Markdown$addToParagraph, _p74, match.match),
										_1: _p73
									};
								}
							} else {
								return newListAS;
							}
						}
					default:
						break _v38_2;
				}
			} else {
				break _v38_2;
			}
		} while(false);
		return newListAS;
	});
var _user$project$Markdown$parseSetextHeadingLine = F2(
	function (match, absSyns) {
		var _p75 = _user$project$Markdown$headingSetextMatch(match);
		var lvl = _p75._0;
		var str = _p75._1;
		var _p76 = absSyns;
		if ((_p76.ctor === '::') && (_p76._0.ctor === 'ParagraphAS')) {
			return {
				ctor: '::',
				_0: _user$project$Markdown$HeadingAS(
					{ctor: '_Tuple2', _0: lvl, _1: _p76._0._0}),
				_1: _p76._1
			};
		} else {
			return _elm_lang$core$Native_Utils.eq(lvl, 1) ? A2(_user$project$Markdown$parseTextLine, match.match, absSyns) : (_elm_lang$core$Native_Utils.eq(str, '-') ? A3(_user$project$Markdown$parseListLine, _user$project$Markdown_Config$Unordered, match, absSyns) : (A2(_elm_lang$core$Regex$contains, _user$project$Markdown$thematicBreakLineRegex, match.match) ? {ctor: '::', _0: _user$project$Markdown$ThematicBreakAS, _1: absSyns} : A2(_user$project$Markdown$parseTextLine, match.match, absSyns)));
		}
	});
var _user$project$Markdown$Html = function (a) {
	return {ctor: 'Html', _0: a};
};
var _user$project$Markdown$List = function (a) {
	return {ctor: 'List', _0: a};
};
var _user$project$Markdown$BlockQuote = function (a) {
	return {ctor: 'BlockQuote', _0: a};
};
var _user$project$Markdown$Paragraph = function (a) {
	return {ctor: 'Paragraph', _0: a};
};
var _user$project$Markdown$Code = function (a) {
	return {ctor: 'Code', _0: a};
};
var _user$project$Markdown$Heading = function (a) {
	return {ctor: 'Heading', _0: a};
};
var _user$project$Markdown$ThematicBreak = {ctor: 'ThematicBreak'};
var _user$project$Markdown$absSynToBlock = F3(
	function (options, refs, absSyn) {
		var _p77 = absSyn;
		switch (_p77.ctor) {
			case 'HeadingAS':
				return _elm_lang$core$Maybe$Just(
					_user$project$Markdown$Heading(
						{
							level: _p77._0._0,
							inlines: A3(_user$project$Markdown_Inline$parse, options, refs, _p77._0._1)
						}));
			case 'ThematicBreakAS':
				return _elm_lang$core$Maybe$Just(_user$project$Markdown$ThematicBreak);
			case 'ParagraphAS':
				var parsedInline = A3(_user$project$Markdown_Inline$parse, options, refs, _p77._0);
				var returnParagraph = _elm_lang$core$Maybe$Just(
					_user$project$Markdown$Paragraph(
						{inlines: parsedInline}));
				var _p78 = parsedInline;
				if ((_p78.ctor === '::') && (_p78._1.ctor === '[]')) {
					var _p79 = _p78._0._0.type_;
					if (_p79.ctor === 'Html') {
						return _elm_lang$core$Maybe$Just(
							_user$project$Markdown$Html(
								{inlines: parsedInline}));
					} else {
						return returnParagraph;
					}
				} else {
					return returnParagraph;
				}
			case 'CodeAS':
				return _elm_lang$core$Maybe$Just(
					_user$project$Markdown$Code(
						_user$project$Markdown$codeASToBlock(_p77._0)));
			case 'BlockQuoteAS':
				return _elm_lang$core$Maybe$Just(
					_user$project$Markdown$BlockQuote(
						{
							blocks: A2(
								_user$project$Markdown$absSynsToBlocks,
								options,
								{ctor: '_Tuple2', _0: refs, _1: _p77._0})
						}));
			case 'ListAS':
				var _p81 = _p77._0;
				return _elm_lang$core$Maybe$Just(
					_user$project$Markdown$List(
						{
							type_: _p81.type_,
							isLoose: _p81.isLoose,
							items: A2(
								_elm_lang$core$List$map,
								function (_p80) {
									return A2(
										_user$project$Markdown$absSynsToBlocks,
										options,
										A2(
											F2(
												function (v0, v1) {
													return {ctor: '_Tuple2', _0: v0, _1: v1};
												}),
											refs,
											_p80));
								},
								_p77._1)
						}));
			default:
				return _elm_lang$core$Maybe$Nothing;
		}
	});
var _user$project$Markdown$absSynsToBlocks = F2(
	function (options, _p82) {
		var _p83 = _p82;
		return A2(
			_elm_lang$core$List$filterMap,
			A2(_user$project$Markdown$absSynToBlock, options, _p83._0),
			_p83._1);
	});
var _user$project$Markdown$toBlocks = F2(
	function (options, rawText) {
		return A2(
			_user$project$Markdown$absSynsToBlocks,
			options,
			A2(
				_user$project$Markdown$parseReferences,
				_elm_lang$core$Dict$empty,
				_user$project$Markdown$parseRawLines(
					{
						ctor: '_Tuple2',
						_0: _user$project$Markdown$toRawLines(rawText),
						_1: {ctor: '[]'}
					})));
	});
var _user$project$Markdown$customHtml = F2(
	function (options, elements) {
		return function (_p84) {
			return A4(
				_user$project$Markdown$blocksToHtml,
				options,
				elements,
				true,
				A2(_user$project$Markdown$toBlocks, options, _p84));
		};
	});
var _user$project$Markdown$withOptions = function (options) {
	return A2(_user$project$Markdown$customHtml, options, _user$project$Markdown_Config$defaultElements);
};
var _user$project$Markdown$toHtml = A2(_user$project$Markdown$customHtml, _user$project$Markdown_Config$defaultOptions, _user$project$Markdown_Config$defaultElements);

var _user$project$App_Markdown$customLinkElement = function (link) {
	return _elm_lang$html$Html$a(
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$href(link.url),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$title(
					A2(_elm_lang$core$Maybe$withDefault, '', link.title)),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$target('_blank'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$rel('noopener noreferrer'),
						_1: {ctor: '[]'}
					}
				}
			}
		});
};
var _user$project$App_Markdown$markdownElements = _elm_lang$core$Native_Utils.update(
	_user$project$Markdown_Config$defaultElements,
	{link: _user$project$App_Markdown$customLinkElement});
var _user$project$App_Markdown$markdownOptions = _elm_lang$core$Native_Utils.update(
	_user$project$Markdown_Config$defaultOptions,
	{softAsHardLineBreak: true});
var _user$project$App_Markdown$markdown = function (content) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('content'),
			_1: {ctor: '[]'}
		},
		A3(_user$project$Markdown$customHtml, _user$project$App_Markdown$markdownOptions, _user$project$App_Markdown$markdownElements, content));
};

var _user$project$Components_CotoModal$update = F2(
	function (msg, model) {
		var _p0 = msg;
		switch (_p0.ctor) {
			case 'Close':
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{open: false}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			case 'ConfirmDelete':
				return {ctor: '_Tuple2', _0: model, _1: _elm_lang$core$Platform_Cmd$none};
			default:
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{open: false}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
		}
	});
var _user$project$Components_CotoModal$initModel = {open: false, coto: _elm_lang$core$Maybe$Nothing};
var _user$project$Components_CotoModal$Model = F2(
	function (a, b) {
		return {open: a, coto: b};
	});
var _user$project$Components_CotoModal$Delete = function (a) {
	return {ctor: 'Delete', _0: a};
};
var _user$project$Components_CotoModal$ConfirmDelete = function (a) {
	return {ctor: 'ConfirmDelete', _0: a};
};
var _user$project$Components_CotoModal$Close = {ctor: 'Close'};
var _user$project$Components_CotoModal$modalConfig = function (model) {
	return {
		closeMessage: _user$project$Components_CotoModal$Close,
		title: function () {
			var _p1 = model.coto;
			if (_p1.ctor === 'Nothing') {
				return '';
			} else {
				return _p1._0.asCotonoma ? 'Cotonoma' : 'Coto';
			}
		}(),
		content: A2(
			_elm_lang$html$Html$div,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('coto'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: function () {
							var _p2 = model.coto;
							if (_p2.ctor === 'Nothing') {
								return A2(
									_elm_lang$html$Html$div,
									{ctor: '[]'},
									{ctor: '[]'});
							} else {
								return _user$project$App_Markdown$markdown(_p2._0.content);
							}
						}(),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}),
		buttons: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$a,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('button'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Events$onClick(
							_user$project$Components_CotoModal$ConfirmDelete('Are you sure you want to delete this coto?')),
						_1: {ctor: '[]'}
					}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Delete'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		}
	};
};
var _user$project$Components_CotoModal$view = function (model) {
	return A2(
		_user$project$Modal$view,
		'coto-modal',
		model.open ? _elm_lang$core$Maybe$Just(
			_user$project$Components_CotoModal$modalConfig(model)) : _elm_lang$core$Maybe$Nothing);
};

var _user$project$Components_CotonomaModal_Messages$AmishiFetched = function (a) {
	return {ctor: 'AmishiFetched', _0: a};
};
var _user$project$Components_CotonomaModal_Messages$RemoveMember = function (a) {
	return {ctor: 'RemoveMember', _0: a};
};
var _user$project$Components_CotonomaModal_Messages$AddMember = {ctor: 'AddMember'};
var _user$project$Components_CotonomaModal_Messages$Posted = function (a) {
	return {ctor: 'Posted', _0: a};
};
var _user$project$Components_CotonomaModal_Messages$Post = {ctor: 'Post'};
var _user$project$Components_CotonomaModal_Messages$MemberEmailInput = function (a) {
	return {ctor: 'MemberEmailInput', _0: a};
};
var _user$project$Components_CotonomaModal_Messages$NameInput = function (a) {
	return {ctor: 'NameInput', _0: a};
};
var _user$project$Components_CotonomaModal_Messages$Close = {ctor: 'Close'};
var _user$project$Components_CotonomaModal_Messages$NoOp = {ctor: 'NoOp'};

var _user$project$App_Messages$CotonomaClick = function (a) {
	return {ctor: 'CotonomaClick', _0: a};
};
var _user$project$App_Messages$CotonomaModalMsg = function (a) {
	return {ctor: 'CotonomaModalMsg', _0: a};
};
var _user$project$App_Messages$OpenCotonomaModal = {ctor: 'OpenCotonomaModal'};
var _user$project$App_Messages$CotoDeleted = function (a) {
	return {ctor: 'CotoDeleted', _0: a};
};
var _user$project$App_Messages$DeleteCoto = function (a) {
	return {ctor: 'DeleteCoto', _0: a};
};
var _user$project$App_Messages$CotoModalMsg = function (a) {
	return {ctor: 'CotoModalMsg', _0: a};
};
var _user$project$App_Messages$TimelineMsg = function (a) {
	return {ctor: 'TimelineMsg', _0: a};
};
var _user$project$App_Messages$ProfileModalMsg = function (a) {
	return {ctor: 'ProfileModalMsg', _0: a};
};
var _user$project$App_Messages$OpenProfileModal = {ctor: 'OpenProfileModal'};
var _user$project$App_Messages$SigninModalMsg = function (a) {
	return {ctor: 'SigninModalMsg', _0: a};
};
var _user$project$App_Messages$OpenSigninModal = {ctor: 'OpenSigninModal'};
var _user$project$App_Messages$ConfirmModalMsg = function (a) {
	return {ctor: 'ConfirmModalMsg', _0: a};
};
var _user$project$App_Messages$KeyUp = function (a) {
	return {ctor: 'KeyUp', _0: a};
};
var _user$project$App_Messages$KeyDown = function (a) {
	return {ctor: 'KeyDown', _0: a};
};
var _user$project$App_Messages$CotonomaFetched = function (a) {
	return {ctor: 'CotonomaFetched', _0: a};
};
var _user$project$App_Messages$HomeClick = {ctor: 'HomeClick'};
var _user$project$App_Messages$SubCotonomasFetched = function (a) {
	return {ctor: 'SubCotonomasFetched', _0: a};
};
var _user$project$App_Messages$RecentCotonomasFetched = function (a) {
	return {ctor: 'RecentCotonomasFetched', _0: a};
};
var _user$project$App_Messages$SessionFetched = function (a) {
	return {ctor: 'SessionFetched', _0: a};
};
var _user$project$App_Messages$NavigationToggle = {ctor: 'NavigationToggle'};
var _user$project$App_Messages$OnLocationChange = function (a) {
	return {ctor: 'OnLocationChange', _0: a};
};
var _user$project$App_Messages$NoOp = {ctor: 'NoOp'};

var _user$project$App_Channels$cotonomaChannel = function (key) {
	return A3(
		_saschatimme$elm_phoenix$Phoenix_Channel$on,
		'post',
		function (payload) {
			return _user$project$App_Messages$TimelineMsg(
				_user$project$Components_Timeline_Messages$PostPushed(payload));
		},
		_saschatimme$elm_phoenix$Phoenix_Channel$init(
			A2(_elm_lang$core$Basics_ops['++'], 'cotonomas:', key)));
};
var _user$project$App_Channels$Payload = F2(
	function (a, b) {
		return {clientId: a, body: b};
	});
var _user$project$App_Channels$decodePayload = F2(
	function (bodyName, bodyDecoder) {
		return A3(
			_elm_lang$core$Json_Decode$map2,
			_user$project$App_Channels$Payload,
			A2(_elm_lang$core$Json_Decode$field, 'clientId', _elm_lang$core$Json_Decode$string),
			A2(_elm_lang$core$Json_Decode$field, bodyName, bodyDecoder));
	});

var _user$project$App_Commands$deleteCoto = function (cotoId) {
	return A2(
		_elm_lang$http$Http$send,
		_user$project$App_Messages$CotoDeleted,
		_elm_lang$http$Http$request(
			{
				method: 'DELETE',
				headers: {ctor: '[]'},
				url: A2(
					_elm_lang$core$Basics_ops['++'],
					'/api/cotos/',
					_elm_lang$core$Basics$toString(cotoId)),
				body: _elm_lang$http$Http$emptyBody,
				expect: _elm_lang$http$Http$expectString,
				timeout: _elm_lang$core$Maybe$Nothing,
				withCredentials: false
			}));
};
var _user$project$App_Commands$fetchCotonoma = function (key) {
	var url = A2(
		_elm_lang$core$Basics_ops['++'],
		'/api/cotonomas/',
		A2(_elm_lang$core$Basics_ops['++'], key, '/cotos'));
	return A2(
		_elm_lang$http$Http$send,
		_user$project$App_Messages$CotonomaFetched,
		A2(
			_elm_lang$http$Http$get,
			url,
			A4(
				_elm_lang$core$Json_Decode$map3,
				F3(
					function (v0, v1, v2) {
						return {ctor: '_Tuple3', _0: v0, _1: v1, _2: v2};
					}),
				A2(_elm_lang$core$Json_Decode$field, 'cotonoma', _user$project$App_Types$decodeCotonoma),
				A2(
					_elm_lang$core$Json_Decode$field,
					'members',
					_elm_lang$core$Json_Decode$list(_user$project$App_Types$decodeAmishi)),
				A2(
					_elm_lang$core$Json_Decode$field,
					'cotos',
					_elm_lang$core$Json_Decode$list(_user$project$Components_Timeline_Model$decodePost)))));
};
var _user$project$App_Commands$fetchAmishi = F2(
	function (msg, email) {
		return A2(
			_elm_lang$http$Http$send,
			msg,
			A2(
				_elm_lang$http$Http$get,
				A2(_elm_lang$core$Basics_ops['++'], '/api/amishis/email/', email),
				_user$project$App_Types$decodeAmishi));
	});
var _user$project$App_Commands$fetchSubCotonomas = function (maybeCotonoma) {
	var _p0 = maybeCotonoma;
	if (_p0.ctor === 'Nothing') {
		return _elm_lang$core$Platform_Cmd$none;
	} else {
		return A2(
			_elm_lang$http$Http$send,
			_user$project$App_Messages$SubCotonomasFetched,
			A2(
				_elm_lang$http$Http$get,
				A2(
					_elm_lang$core$Basics_ops['++'],
					'/api/cotonomas?cotonoma_id=',
					_elm_lang$core$Basics$toString(_p0._0.id)),
				_elm_lang$core$Json_Decode$list(_user$project$App_Types$decodeCotonoma)));
	}
};
var _user$project$App_Commands$fetchRecentCotonomas = A2(
	_elm_lang$http$Http$send,
	_user$project$App_Messages$RecentCotonomasFetched,
	A2(
		_elm_lang$http$Http$get,
		'/api/cotonomas',
		_elm_lang$core$Json_Decode$list(_user$project$App_Types$decodeCotonoma)));
var _user$project$App_Commands$fetchSession = A2(
	_elm_lang$http$Http$send,
	_user$project$App_Messages$SessionFetched,
	A2(_elm_lang$http$Http$get, '/api/session', _user$project$App_Types$decodeSession));

var _user$project$Components_ConfirmModal_Model$initModel = {open: false, message: '', msgOnConfirm: _user$project$App_Messages$NoOp};
var _user$project$Components_ConfirmModal_Model$Model = F3(
	function (a, b, c) {
		return {open: a, message: b, msgOnConfirm: c};
	});

var _user$project$Components_CotonomaModal_Model$containsMember = F3(
	function (session, model, email) {
		return _elm_lang$core$Native_Utils.eq(session.email, email) ? true : A2(
			_elm_lang$core$List$any,
			function (member) {
				var _p0 = member;
				if (_p0.ctor === 'SignedUp') {
					return _elm_lang$core$Native_Utils.eq(_p0._0.email, email);
				} else {
					return _elm_lang$core$Native_Utils.eq(_p0._0, email);
				}
			},
			model.members);
	});
var _user$project$Components_CotonomaModal_Model$removeMember = F2(
	function (email, model) {
		return _elm_lang$core$Native_Utils.update(
			model,
			{
				members: A2(
					_elm_lang$core$List$filter,
					function (member) {
						var _p1 = member;
						if (_p1.ctor === 'SignedUp') {
							return !_elm_lang$core$Native_Utils.eq(_p1._0.email, email);
						} else {
							return !_elm_lang$core$Native_Utils.eq(_p1._0, email);
						}
					},
					model.members)
			});
	});
var _user$project$Components_CotonomaModal_Model$addMember = F3(
	function (session, member, model) {
		var email = function () {
			var _p2 = member;
			if (_p2.ctor === 'SignedUp') {
				return _p2._0.email;
			} else {
				return _p2._0;
			}
		}();
		var members = A3(_user$project$Components_CotonomaModal_Model$containsMember, session, model, email) ? model.members : {ctor: '::', _0: member, _1: model.members};
		return _elm_lang$core$Native_Utils.update(
			model,
			{members: members, membersLoading: false, memberEmail: '', memberEmailValid: false});
	});
var _user$project$Components_CotonomaModal_Model$initModel = {
	open: false,
	name: '',
	memberEmail: '',
	memberEmailValid: false,
	membersLoading: false,
	members: {ctor: '[]'}
};
var _user$project$Components_CotonomaModal_Model$Model = F6(
	function (a, b, c, d, e, f) {
		return {open: a, name: b, memberEmail: c, memberEmailValid: d, membersLoading: e, members: f};
	});
var _user$project$Components_CotonomaModal_Model$NotYetSignedUp = function (a) {
	return {ctor: 'NotYetSignedUp', _0: a};
};
var _user$project$Components_CotonomaModal_Model$SignedUp = function (a) {
	return {ctor: 'SignedUp', _0: a};
};
var _user$project$Components_CotonomaModal_Model$setDefaultMembers = F3(
	function (session, amishis, model) {
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (amishi, model) {
					return A3(
						_user$project$Components_CotonomaModal_Model$addMember,
						session,
						_user$project$Components_CotonomaModal_Model$SignedUp(amishi),
						model);
				}),
			_elm_lang$core$Native_Utils.update(
				model,
				{
					members: {ctor: '[]'}
				}),
			amishis);
	});

var _user$project$App_Model$getOwnerAndMembers = function (model) {
	var _p0 = model.cotonoma;
	if (_p0.ctor === 'Nothing') {
		return {ctor: '[]'};
	} else {
		var _p1 = _p0._0.owner;
		if (_p1.ctor === 'Nothing') {
			return model.members;
		} else {
			return {ctor: '::', _0: _p1._0, _1: model.members};
		}
	}
};
var _user$project$App_Model$isNavigationEmpty = function (model) {
	return _krisajenkins$elm_exts$Exts_Maybe$isNothing(model.cotonoma) && (_elm_lang$core$List$isEmpty(model.recentCotonomas) && _elm_lang$core$List$isEmpty(model.subCotonomas));
};
var _user$project$App_Model$initModel = F2(
	function (seed, route) {
		var _p2 = A2(
			_mgold$elm_random_pcg$Random_Pcg$step,
			_danyx23$elm_uuid$Uuid$uuidGenerator,
			_mgold$elm_random_pcg$Random_Pcg$initialSeed(seed));
		var newUuid = _p2._0;
		var newSeed = _p2._1;
		return {
			clientId: _danyx23$elm_uuid$Uuid$toString(newUuid),
			route: route,
			ctrlDown: false,
			navigationToggled: false,
			navigationOpen: false,
			session: _elm_lang$core$Maybe$Nothing,
			cotonoma: _elm_lang$core$Maybe$Nothing,
			members: {ctor: '[]'},
			confirmModal: _user$project$Components_ConfirmModal_Model$initModel,
			signinModal: _user$project$Components_SigninModal$initModel,
			profileModal: _user$project$Components_ProfileModal$initModel,
			cotoModal: _user$project$Components_CotoModal$initModel,
			recentCotonomas: {ctor: '[]'},
			cotonomasLoading: false,
			subCotonomas: {ctor: '[]'},
			timeline: _user$project$Components_Timeline_Model$initModel,
			activeCotoId: _elm_lang$core$Maybe$Nothing,
			cotonomaModal: _user$project$Components_CotonomaModal_Model$initModel
		};
	});
var _user$project$App_Model$Model = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return function (l) {
												return function (m) {
													return function (n) {
														return function (o) {
															return function (p) {
																return function (q) {
																	return function (r) {
																		return {clientId: a, route: b, ctrlDown: c, navigationToggled: d, navigationOpen: e, session: f, cotonoma: g, members: h, confirmModal: i, signinModal: j, profileModal: k, cotoModal: l, recentCotonomas: m, cotonomasLoading: n, subCotonomas: o, timeline: p, activeCotoId: q, cotonomaModal: r};
																	};
																};
															};
														};
													};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};

var _user$project$App_Routing$matchers = _evancz$url_parser$UrlParser$oneOf(
	{
		ctor: '::',
		_0: A2(_evancz$url_parser$UrlParser$map, _user$project$App_Types$HomeRoute, _evancz$url_parser$UrlParser$top),
		_1: {
			ctor: '::',
			_0: A2(
				_evancz$url_parser$UrlParser$map,
				_user$project$App_Types$CotonomaRoute,
				A2(
					_evancz$url_parser$UrlParser_ops['</>'],
					_evancz$url_parser$UrlParser$s('cotonomas'),
					_evancz$url_parser$UrlParser$string)),
			_1: {ctor: '[]'}
		}
	});
var _user$project$App_Routing$parseLocation = function (location) {
	var _p0 = A2(_evancz$url_parser$UrlParser$parsePath, _user$project$App_Routing$matchers, location);
	if (_p0.ctor === 'Just') {
		return _p0._0;
	} else {
		return _user$project$App_Types$NotFoundRoute;
	}
};

var _user$project$App_Subscriptions$socket = F2(
	function (token, websocketUrl) {
		return A2(
			_saschatimme$elm_phoenix$Phoenix_Socket$withParams,
			{
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'token', _1: token},
				_1: {ctor: '[]'}
			},
			_saschatimme$elm_phoenix$Phoenix_Socket$init(websocketUrl));
	});
var _user$project$App_Subscriptions$phoenixChannels = function (model) {
	var _p0 = model.session;
	if (_p0.ctor === 'Nothing') {
		return _elm_lang$core$Platform_Sub$none;
	} else {
		var _p2 = _p0._0;
		var _p1 = model.cotonoma;
		if (_p1.ctor === 'Nothing') {
			return _elm_lang$core$Platform_Sub$none;
		} else {
			return A2(
				_saschatimme$elm_phoenix$Phoenix$connect,
				A2(_user$project$App_Subscriptions$socket, _p2.token, _p2.websocketUrl),
				{
					ctor: '::',
					_0: _user$project$App_Channels$cotonomaChannel(_p1._0.key),
					_1: {ctor: '[]'}
				});
		}
	}
};
var _user$project$App_Subscriptions$subscriptions = function (model) {
	return _elm_lang$core$Platform_Sub$batch(
		{
			ctor: '::',
			_0: _elm_lang$keyboard$Keyboard$downs(_user$project$App_Messages$KeyDown),
			_1: {
				ctor: '::',
				_0: _elm_lang$keyboard$Keyboard$ups(_user$project$App_Messages$KeyUp),
				_1: {
					ctor: '::',
					_0: _user$project$App_Subscriptions$phoenixChannels(model),
					_1: {ctor: '[]'}
				}
			}
		});
};

var _user$project$Keys$zero = {keyCode: 58, name: '0'};
var _user$project$Keys$nine = {keyCode: 57, name: '9'};
var _user$project$Keys$eight = {keyCode: 56, name: '8'};
var _user$project$Keys$seven = {keyCode: 55, name: '7'};
var _user$project$Keys$six = {keyCode: 54, name: '6'};
var _user$project$Keys$five = {keyCode: 53, name: '5'};
var _user$project$Keys$four = {keyCode: 52, name: '4'};
var _user$project$Keys$three = {keyCode: 51, name: '3'};
var _user$project$Keys$two = {keyCode: 50, name: '2'};
var _user$project$Keys$one = {keyCode: 49, name: '1'};
var _user$project$Keys$f10 = {keyCode: 121, name: 'F10'};
var _user$project$Keys$f9 = {keyCode: 120, name: 'F9'};
var _user$project$Keys$f8 = {keyCode: 119, name: 'F8'};
var _user$project$Keys$f4 = {keyCode: 115, name: 'F4'};
var _user$project$Keys$f2 = {keyCode: 113, name: 'F2'};
var _user$project$Keys$escape = {keyCode: 27, name: 'Escape'};
var _user$project$Keys$pageUp = {keyCode: 33, name: 'Page up'};
var _user$project$Keys$pageDown = {keyCode: 34, name: 'Page down'};
var _user$project$Keys$home = {keyCode: 36, name: 'Home'};
var _user$project$Keys$end = {keyCode: 35, name: 'End'};
var _user$project$Keys$insert = {keyCode: 45, name: 'Insert'};
var _user$project$Keys$delete = {keyCode: 46, name: 'Delete'};
var _user$project$Keys$backspace = {keyCode: 8, name: 'Backspace'};
var _user$project$Keys$arrowDown = {keyCode: 40, name: 'Down arrow'};
var _user$project$Keys$arrowUp = {keyCode: 38, name: 'Up arrow'};
var _user$project$Keys$arrowLeft = {keyCode: 39, name: 'Left arrow'};
var _user$project$Keys$arrowRight = {keyCode: 37, name: 'Right arrow'};
var _user$project$Keys$enter = {keyCode: 13, name: 'Enter'};
var _user$project$Keys$space = {keyCode: 32, name: 'Space'};
var _user$project$Keys$commandRight = {keyCode: 93, name: 'Command right'};
var _user$project$Keys$commandLeft = {keyCode: 91, name: 'Command left'};
var _user$project$Keys$windows = {keyCode: 91, name: 'Windows'};
var _user$project$Keys$meta = {keyCode: 91, name: 'Meta'};
var _user$project$Keys$super = {keyCode: 91, name: 'Super'};
var _user$project$Keys$tab = {keyCode: 9, name: 'Tab'};
var _user$project$Keys$shift = {keyCode: 16, name: 'Shift'};
var _user$project$Keys$ctrl = {keyCode: 17, name: 'Ctrl'};
var _user$project$Keys$z = {keyCode: 90, name: 'z'};
var _user$project$Keys$y = {keyCode: 89, name: 'y'};
var _user$project$Keys$x = {keyCode: 88, name: 'x'};
var _user$project$Keys$w = {keyCode: 87, name: 'w'};
var _user$project$Keys$v = {keyCode: 86, name: 'v'};
var _user$project$Keys$u = {keyCode: 85, name: 'u'};
var _user$project$Keys$t = {keyCode: 84, name: 't'};
var _user$project$Keys$s = {keyCode: 83, name: 's'};
var _user$project$Keys$r = {keyCode: 82, name: 'r'};
var _user$project$Keys$q = {keyCode: 81, name: 'q'};
var _user$project$Keys$p = {keyCode: 80, name: 'p'};
var _user$project$Keys$o = {keyCode: 79, name: 'o'};
var _user$project$Keys$n = {keyCode: 78, name: 'n'};
var _user$project$Keys$m = {keyCode: 77, name: 'm'};
var _user$project$Keys$l = {keyCode: 76, name: 'l'};
var _user$project$Keys$k = {keyCode: 75, name: 'k'};
var _user$project$Keys$j = {keyCode: 74, name: 'j'};
var _user$project$Keys$i = {keyCode: 73, name: 'i'};
var _user$project$Keys$h = {keyCode: 72, name: 'h'};
var _user$project$Keys$g = {keyCode: 71, name: 'g'};
var _user$project$Keys$f = {keyCode: 70, name: 'f'};
var _user$project$Keys$e = {keyCode: 69, name: 'e'};
var _user$project$Keys$d = {keyCode: 68, name: 'd'};
var _user$project$Keys$c = {keyCode: 67, name: 'b'};
var _user$project$Keys$b = {keyCode: 66, name: 'b'};
var _user$project$Keys$a = {keyCode: 65, name: 'a'};
var _user$project$Keys$equals = F2(
	function (k0, k1) {
		return _elm_lang$core$Native_Utils.eq(k0.keyCode, k1.keyCode);
	});
var _user$project$Keys$Key = F2(
	function (a, b) {
		return {keyCode: a, name: b};
	});

var _user$project$Components_ConfirmModal_Update$update = F2(
	function (msg, model) {
		var _p0 = msg;
		if (_p0.ctor === 'Close') {
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_Utils.update(
					model,
					{open: false}),
				_1: _elm_lang$core$Platform_Cmd$none
			};
		} else {
			return {
				ctor: '_Tuple2',
				_0: _elm_lang$core$Native_Utils.update(
					model,
					{open: false}),
				_1: A2(
					_elm_lang$core$Task$perform,
					function (_p1) {
						return model.msgOnConfirm;
					},
					_elm_lang$core$Task$succeed(
						{ctor: '_Tuple0'}))
			};
		}
	});

var _user$project$Components_Timeline_Commands$encodePost = F3(
	function (clientId, maybeCotonoma, post) {
		return _elm_lang$core$Json_Encode$object(
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'clientId',
					_1: _elm_lang$core$Json_Encode$string(clientId)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'coto',
						_1: _elm_lang$core$Json_Encode$object(
							{
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'cotonoma_id',
									_1: function () {
										var _p0 = maybeCotonoma;
										if (_p0.ctor === 'Nothing') {
											return _elm_lang$core$Json_Encode$null;
										} else {
											return _elm_lang$core$Json_Encode$int(_p0._0.id);
										}
									}()
								},
								_1: {
									ctor: '::',
									_0: {
										ctor: '_Tuple2',
										_0: 'postId',
										_1: function () {
											var _p1 = post.postId;
											if (_p1.ctor === 'Nothing') {
												return _elm_lang$core$Json_Encode$null;
											} else {
												return _elm_lang$core$Json_Encode$int(_p1._0);
											}
										}()
									},
									_1: {
										ctor: '::',
										_0: {
											ctor: '_Tuple2',
											_0: 'content',
											_1: _elm_lang$core$Json_Encode$string(post.content)
										},
										_1: {ctor: '[]'}
									}
								}
							})
					},
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Components_Timeline_Commands$post = F3(
	function (clientId, maybeCotonoma, post) {
		return A2(
			_elm_lang$http$Http$send,
			_user$project$Components_Timeline_Messages$Posted,
			A3(
				_elm_lang$http$Http$post,
				'/api/cotos',
				_elm_lang$http$Http$jsonBody(
					A3(_user$project$Components_Timeline_Commands$encodePost, clientId, maybeCotonoma, post)),
				_user$project$Components_Timeline_Model$decodePost));
	});
var _user$project$Components_Timeline_Commands$fetchPosts = A2(
	_elm_lang$http$Http$send,
	_user$project$Components_Timeline_Messages$PostsFetched,
	A2(
		_elm_lang$http$Http$get,
		'/api/cotos',
		_elm_lang$core$Json_Decode$list(_user$project$Components_Timeline_Model$decodePost)));
var _user$project$Components_Timeline_Commands$scrollToBottom = function (msg) {
	return A2(
		_elm_lang$core$Task$attempt,
		function (_p2) {
			return msg;
		},
		A2(
			_elm_lang$core$Task$andThen,
			function (_p3) {
				return _elm_lang$dom$Dom_Scroll$toBottom('timeline');
			},
			_elm_lang$core$Process$sleep(1 * _elm_lang$core$Time$millisecond)));
};

var _user$project$Components_Timeline_Update$setCotoSaved = F2(
	function (response, post) {
		return _elm_lang$core$Native_Utils.eq(post.postId, response.postId) ? _elm_lang$core$Native_Utils.update(
			post,
			{cotoId: response.cotoId, cotonomaKey: response.cotonomaKey}) : post;
	});
var _user$project$Components_Timeline_Update$post = F3(
	function (clientId, maybeCotonoma, model) {
		var postId = model.postIdCounter + 1;
		var newPost = _elm_lang$core$Native_Utils.update(
			_user$project$Components_Timeline_Model$defaultPost,
			{
				postId: _elm_lang$core$Maybe$Just(postId),
				content: model.newContent,
				postedIn: maybeCotonoma
			});
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			_elm_lang$core$Native_Utils.update(
				model,
				{
					posts: {ctor: '::', _0: newPost, _1: model.posts},
					postIdCounter: postId,
					newContent: ''
				}),
			{
				ctor: '::',
				_0: _user$project$Components_Timeline_Commands$scrollToBottom(_user$project$Components_Timeline_Messages$NoOp),
				_1: {
					ctor: '::',
					_0: A3(_user$project$Components_Timeline_Commands$post, clientId, maybeCotonoma, newPost),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Components_Timeline_Update$handlePushedPost = F3(
	function (clientId, payload, model) {
		return (!_elm_lang$core$Native_Utils.eq(payload.clientId, clientId)) ? A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			_elm_lang$core$Native_Utils.update(
				model,
				{
					posts: {ctor: '::', _0: payload.body, _1: model.posts}
				}),
			{
				ctor: '::',
				_0: _user$project$Components_Timeline_Commands$scrollToBottom(_user$project$Components_Timeline_Messages$NoOp),
				_1: payload.body.asCotonoma ? {
					ctor: '::',
					_0: A2(
						_elm_lang$core$Task$perform,
						function (_p0) {
							return _user$project$Components_Timeline_Messages$CotonomaPushed(payload.body);
						},
						_elm_lang$core$Task$succeed(
							{ctor: '_Tuple0'})),
					_1: {ctor: '[]'}
				} : {ctor: '[]'}
			}) : A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			model,
			{ctor: '[]'});
	});
var _user$project$Components_Timeline_Update$update = F5(
	function (clientId, maybeCotonoma, ctrlDown, msg, model) {
		var _p1 = msg;
		switch (_p1.ctor) {
			case 'NoOp':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'PostsFetched':
				if (_p1._0.ctor === 'Ok') {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							model,
							{posts: _p1._0._0, loading: false}),
						_1: _user$project$Components_Timeline_Commands$scrollToBottom(_user$project$Components_Timeline_Messages$NoOp)
					};
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				}
			case 'ImageLoaded':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{
						ctor: '::',
						_0: _user$project$Components_Timeline_Commands$scrollToBottom(_user$project$Components_Timeline_Messages$NoOp),
						_1: {ctor: '[]'}
					});
			case 'PostClick':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'EditorFocus':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{editingNew: true}),
					{ctor: '[]'});
			case 'EditorBlur':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{editingNew: false}),
					{ctor: '[]'});
			case 'EditorInput':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{newContent: _p1._0}),
					{ctor: '[]'});
			case 'EditorKeyDown':
				return (_elm_lang$core$Native_Utils.eq(_p1._0, _user$project$Keys$enter.keyCode) && (ctrlDown && (!_user$project$Utils$isBlank(model.newContent)))) ? A3(_user$project$Components_Timeline_Update$post, clientId, maybeCotonoma, model) : A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'Post':
				return A3(_user$project$Components_Timeline_Update$post, clientId, maybeCotonoma, model);
			case 'Posted':
				if (_p1._0.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{
								posts: A2(
									_elm_lang$core$List$map,
									function (post) {
										return A2(_user$project$Components_Timeline_Update$setCotoSaved, _p1._0._0, post);
									},
									model.posts)
							}),
						{ctor: '[]'});
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				}
			case 'PostOpen':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'CotonomaClick':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'PostPushed':
				var _p2 = A2(
					_elm_lang$core$Json_Decode$decodeValue,
					A2(_user$project$App_Channels$decodePayload, 'post', _user$project$Components_Timeline_Model$decodePost),
					_p1._0);
				if (_p2.ctor === 'Ok') {
					return A3(_user$project$Components_Timeline_Update$handlePushedPost, clientId, _p2._0, model);
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				}
			default:
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
		}
	});

var _user$project$Components_CotonomaModal_Commands$encodeMember = function (member) {
	return _elm_lang$core$Json_Encode$object(
		{
			ctor: '::',
			_0: function () {
				var _p0 = member;
				if (_p0.ctor === 'SignedUp') {
					return {
						ctor: '_Tuple2',
						_0: 'amishi_id',
						_1: _elm_lang$core$Json_Encode$int(_p0._0.id)
					};
				} else {
					return {
						ctor: '_Tuple2',
						_0: 'email',
						_1: _elm_lang$core$Json_Encode$string(_p0._0)
					};
				}
			}(),
			_1: {ctor: '[]'}
		});
};
var _user$project$Components_CotonomaModal_Commands$encodeCotonoma = F5(
	function (clientId, maybeCotonoma, postId, members, name) {
		return _elm_lang$core$Json_Encode$object(
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'clientId',
					_1: _elm_lang$core$Json_Encode$string(clientId)
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'cotonoma',
						_1: _elm_lang$core$Json_Encode$object(
							{
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'cotonoma_id',
									_1: function () {
										var _p1 = maybeCotonoma;
										if (_p1.ctor === 'Nothing') {
											return _elm_lang$core$Json_Encode$null;
										} else {
											return _elm_lang$core$Json_Encode$int(_p1._0.id);
										}
									}()
								},
								_1: {
									ctor: '::',
									_0: {
										ctor: '_Tuple2',
										_0: 'postId',
										_1: _elm_lang$core$Json_Encode$int(postId)
									},
									_1: {
										ctor: '::',
										_0: {
											ctor: '_Tuple2',
											_0: 'name',
											_1: _elm_lang$core$Json_Encode$string(name)
										},
										_1: {
											ctor: '::',
											_0: {
												ctor: '_Tuple2',
												_0: 'members',
												_1: _elm_lang$core$Json_Encode$list(
													A2(
														_elm_lang$core$List$map,
														function (m) {
															return _user$project$Components_CotonomaModal_Commands$encodeMember(m);
														},
														members))
											},
											_1: {ctor: '[]'}
										}
									}
								}
							})
					},
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Components_CotonomaModal_Commands$postCotonoma = F5(
	function (clientId, maybeCotonoma, postId, members, name) {
		return A2(
			_elm_lang$http$Http$send,
			_user$project$Components_CotonomaModal_Messages$Posted,
			A3(
				_elm_lang$http$Http$post,
				'/api/cotonomas',
				_elm_lang$http$Http$jsonBody(
					A5(_user$project$Components_CotonomaModal_Commands$encodeCotonoma, clientId, maybeCotonoma, postId, members, name)),
				_user$project$Components_Timeline_Model$decodePost));
	});

var _user$project$Components_CotonomaModal_Update$update = F6(
	function (clientId, session, maybeCotonoma, msg, timeline, model) {
		var _p0 = msg;
		switch (_p0.ctor) {
			case 'NoOp':
				return {ctor: '_Tuple3', _0: model, _1: timeline, _2: _elm_lang$core$Platform_Cmd$none};
			case 'Close':
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{open: false}),
					_1: timeline,
					_2: _elm_lang$core$Platform_Cmd$none
				};
			case 'NameInput':
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{name: _p0._0}),
					_1: timeline,
					_2: _elm_lang$core$Platform_Cmd$none
				};
			case 'MemberEmailInput':
				var _p1 = _p0._0;
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{
							memberEmail: _p1,
							memberEmailValid: _user$project$Utils$validateEmail(_p1)
						}),
					_1: timeline,
					_2: _elm_lang$core$Platform_Cmd$none
				};
			case 'AddMember':
				return {
					ctor: '_Tuple3',
					_0: _elm_lang$core$Native_Utils.update(
						model,
						{membersLoading: true}),
					_1: timeline,
					_2: A2(_user$project$App_Commands$fetchAmishi, _user$project$Components_CotonomaModal_Messages$AmishiFetched, model.memberEmail)
				};
			case 'AmishiFetched':
				if (_p0._0.ctor === 'Ok') {
					return {
						ctor: '_Tuple3',
						_0: A3(
							_user$project$Components_CotonomaModal_Model$addMember,
							session,
							_user$project$Components_CotonomaModal_Model$SignedUp(_p0._0._0),
							model),
						_1: timeline,
						_2: _elm_lang$core$Platform_Cmd$none
					};
				} else {
					return {
						ctor: '_Tuple3',
						_0: A3(
							_user$project$Components_CotonomaModal_Model$addMember,
							session,
							_user$project$Components_CotonomaModal_Model$NotYetSignedUp(model.memberEmail),
							model),
						_1: timeline,
						_2: _elm_lang$core$Platform_Cmd$none
					};
				}
			case 'RemoveMember':
				return {
					ctor: '_Tuple3',
					_0: A2(_user$project$Components_CotonomaModal_Model$removeMember, _p0._0, model),
					_1: timeline,
					_2: _elm_lang$core$Platform_Cmd$none
				};
			case 'Post':
				var defaultPost = _user$project$Components_Timeline_Model$defaultPost;
				var postId = timeline.postIdCounter + 1;
				var newPost = _elm_lang$core$Native_Utils.update(
					defaultPost,
					{
						postId: _elm_lang$core$Maybe$Just(postId),
						content: model.name,
						postedIn: maybeCotonoma,
						asCotonoma: true
					});
				return {
					ctor: '_Tuple3',
					_0: _user$project$Components_CotonomaModal_Model$initModel,
					_1: _elm_lang$core$Native_Utils.update(
						timeline,
						{
							posts: {ctor: '::', _0: newPost, _1: timeline.posts},
							postIdCounter: postId
						}),
					_2: _elm_lang$core$Platform_Cmd$batch(
						{
							ctor: '::',
							_0: _user$project$Components_Timeline_Commands$scrollToBottom(_user$project$Components_CotonomaModal_Messages$NoOp),
							_1: {
								ctor: '::',
								_0: A5(_user$project$Components_CotonomaModal_Commands$postCotonoma, clientId, maybeCotonoma, postId, model.members, model.name),
								_1: {ctor: '[]'}
							}
						})
				};
			default:
				if (_p0._0.ctor === 'Ok') {
					var _p2 = A5(
						_user$project$Components_Timeline_Update$update,
						clientId,
						maybeCotonoma,
						false,
						_user$project$Components_Timeline_Messages$Posted(
							_elm_lang$core$Result$Ok(_p0._0._0)),
						timeline);
					var newTimeline = _p2._0;
					return {ctor: '_Tuple3', _0: model, _1: newTimeline, _2: _elm_lang$core$Platform_Cmd$none};
				} else {
					return {ctor: '_Tuple3', _0: model, _1: timeline, _2: _elm_lang$core$Platform_Cmd$none};
				}
		}
	});

var _user$project$App_Update$newActiveCotoId = F2(
	function (currentActiveId, clickedId) {
		var _p0 = currentActiveId;
		if (_p0.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Just(clickedId);
		} else {
			return _elm_lang$core$Native_Utils.eq(clickedId, _p0._0) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(clickedId);
		}
	});
var _user$project$App_Update$loadCotonoma = F2(
	function (key, model) {
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			_elm_lang$core$Native_Utils.update(
				model,
				{
					cotonoma: _elm_lang$core$Maybe$Nothing,
					members: {ctor: '[]'},
					cotonomasLoading: true,
					timeline: _user$project$Components_Timeline_Model$setLoading(model.timeline)
				}),
			{
				ctor: '::',
				_0: _user$project$App_Commands$fetchRecentCotonomas,
				_1: {
					ctor: '::',
					_0: _user$project$App_Commands$fetchCotonoma(key),
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$App_Update$changeLocationToCotonoma = F2(
	function (key, model) {
		return {
			ctor: '_Tuple2',
			_0: model,
			_1: _elm_lang$navigation$Navigation$newUrl(
				A2(_elm_lang$core$Basics_ops['++'], '/cotonomas/', key))
		};
	});
var _user$project$App_Update$loadHome = function (model) {
	return A2(
		_elm_lang$core$Platform_Cmd_ops['!'],
		_elm_lang$core$Native_Utils.update(
			model,
			{
				cotonoma: _elm_lang$core$Maybe$Nothing,
				members: {ctor: '[]'},
				cotonomasLoading: true,
				subCotonomas: {ctor: '[]'},
				timeline: _user$project$Components_Timeline_Model$setLoading(model.timeline)
			}),
		{
			ctor: '::',
			_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$TimelineMsg, _user$project$Components_Timeline_Commands$fetchPosts),
			_1: {
				ctor: '::',
				_0: _user$project$App_Commands$fetchRecentCotonomas,
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$App_Update$changeLocationToHome = function (model) {
	return {
		ctor: '_Tuple2',
		_0: model,
		_1: _elm_lang$navigation$Navigation$newUrl('/')
	};
};
var _user$project$App_Update$update = F2(
	function (msg, model) {
		var _p1 = msg;
		switch (_p1.ctor) {
			case 'NoOp':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'OnLocationChange':
				var newRoute = _user$project$App_Routing$parseLocation(_p1._0);
				var newModel = _elm_lang$core$Native_Utils.update(
					model,
					{route: newRoute});
				var _p2 = newRoute;
				switch (_p2.ctor) {
					case 'HomeRoute':
						return _user$project$App_Update$loadHome(model);
					case 'CotonomaRoute':
						return A2(_user$project$App_Update$loadCotonoma, _p2._0, newModel);
					default:
						return {ctor: '_Tuple2', _0: newModel, _1: _elm_lang$core$Platform_Cmd$none};
				}
			case 'SessionFetched':
				if (_p1._0.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{
								session: _elm_lang$core$Maybe$Just(_p1._0._0)
							}),
						{ctor: '[]'});
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				}
			case 'RecentCotonomasFetched':
				if (_p1._0.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{recentCotonomas: _p1._0._0, cotonomasLoading: false}),
						{ctor: '[]'});
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{cotonomasLoading: false}),
						{ctor: '[]'});
				}
			case 'SubCotonomasFetched':
				if (_p1._0.ctor === 'Ok') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{subCotonomas: _p1._0._0}),
						{ctor: '[]'});
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				}
			case 'NavigationToggle':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{navigationToggled: true, navigationOpen: !model.navigationOpen}),
					{ctor: '[]'});
			case 'HomeClick':
				return _user$project$App_Update$changeLocationToHome(model);
			case 'CotonomaFetched':
				if (_p1._0.ctor === 'Ok') {
					var _p4 = _p1._0._0._0;
					var _p3 = A5(
						_user$project$Components_Timeline_Update$update,
						model.clientId,
						model.cotonoma,
						model.ctrlDown,
						_user$project$Components_Timeline_Messages$PostsFetched(
							_elm_lang$core$Result$Ok(_p1._0._0._2)),
						model.timeline);
					var timeline = _p3._0;
					var cmd = _p3._1;
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						_elm_lang$core$Native_Utils.update(
							model,
							{
								cotonoma: _elm_lang$core$Maybe$Just(_p4),
								members: _p1._0._0._1,
								navigationOpen: false,
								timeline: timeline
							}),
						{
							ctor: '::',
							_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$TimelineMsg, cmd),
							_1: {
								ctor: '::',
								_0: _user$project$App_Commands$fetchSubCotonomas(
									_elm_lang$core$Maybe$Just(_p4)),
								_1: {ctor: '[]'}
							}
						});
				} else {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				}
			case 'KeyDown':
				var _p5 = _p1._0;
				return (_elm_lang$core$Native_Utils.eq(_p5, _user$project$Keys$ctrl.keyCode) || _elm_lang$core$Native_Utils.eq(_p5, _user$project$Keys$meta.keyCode)) ? A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{ctrlDown: true}),
					{ctor: '[]'}) : A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'KeyUp':
				var _p6 = _p1._0;
				return (_elm_lang$core$Native_Utils.eq(_p6, _user$project$Keys$ctrl.keyCode) || _elm_lang$core$Native_Utils.eq(_p6, _user$project$Keys$meta.keyCode)) ? A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{ctrlDown: false}),
					{ctor: '[]'}) : A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'ConfirmModalMsg':
				var _p7 = A2(_user$project$Components_ConfirmModal_Update$update, _p1._0, model.confirmModal);
				var confirmModal = _p7._0;
				var cmd = _p7._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{confirmModal: confirmModal}),
					{
						ctor: '::',
						_0: cmd,
						_1: {ctor: '[]'}
					});
			case 'OpenSigninModal':
				var signinModal = model.signinModal;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							signinModal: _elm_lang$core$Native_Utils.update(
								signinModal,
								{open: true})
						}),
					{ctor: '[]'});
			case 'SigninModalMsg':
				var _p8 = A2(_user$project$Components_SigninModal$update, _p1._0, model.signinModal);
				var signinModal = _p8._0;
				var cmd = _p8._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{signinModal: signinModal}),
					{
						ctor: '::',
						_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$SigninModalMsg, cmd),
						_1: {ctor: '[]'}
					});
			case 'OpenProfileModal':
				var profileModal = model.profileModal;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							profileModal: _elm_lang$core$Native_Utils.update(
								profileModal,
								{open: true})
						}),
					{ctor: '[]'});
			case 'ProfileModalMsg':
				var _p9 = A2(_user$project$Components_ProfileModal$update, _p1._0, model.profileModal);
				var profileModal = _p9._0;
				var cmd = _p9._1;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{profileModal: profileModal}),
					{
						ctor: '::',
						_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$ProfileModalMsg, cmd),
						_1: {ctor: '[]'}
					});
			case 'CotoModalMsg':
				var _p16 = _p1._0;
				var timeline = model.timeline;
				var posts = timeline.posts;
				var confirmModal = model.confirmModal;
				var _p10 = A2(_user$project$Components_CotoModal$update, _p16, model.cotoModal);
				var cotoModal = _p10._0;
				var cmd = _p10._1;
				var _p11 = _p16;
				switch (_p11.ctor) {
					case 'ConfirmDelete':
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{
									cotoModal: cotoModal,
									confirmModal: _elm_lang$core$Native_Utils.update(
										confirmModal,
										{
											open: true,
											message: _p11._0,
											msgOnConfirm: function () {
												var _p12 = cotoModal.coto;
												if (_p12.ctor === 'Nothing') {
													return _user$project$App_Messages$NoOp;
												} else {
													return _user$project$App_Messages$CotoModalMsg(
														_user$project$Components_CotoModal$Delete(_p12._0));
												}
											}()
										})
								}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$CotoModalMsg, cmd),
								_1: {ctor: '[]'}
							});
					case 'Delete':
						var _p15 = _p11._0;
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{
									cotoModal: cotoModal,
									timeline: _elm_lang$core$Native_Utils.update(
										timeline,
										{
											posts: A2(
												_elm_lang$core$List$map,
												function (post) {
													return A2(_user$project$Components_Timeline_Model$isSelfOrPostedIn, _p15, post) ? _elm_lang$core$Native_Utils.update(
														post,
														{beingDeleted: true}) : post;
												},
												posts)
										})
								}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$CotoModalMsg, cmd),
								_1: {
									ctor: '::',
									_0: _user$project$App_Commands$deleteCoto(_p15.id),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$core$Task$perform,
											function (_p13) {
												return _user$project$App_Messages$DeleteCoto(_p15);
											},
											A2(
												_elm_lang$core$Task$andThen,
												function (_p14) {
													return _elm_lang$core$Task$succeed(
														{ctor: '_Tuple0'});
												},
												_elm_lang$core$Process$sleep(1 * _elm_lang$core$Time$second))),
										_1: {ctor: '[]'}
									}
								}
							});
					default:
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{cotoModal: cotoModal}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$CotoModalMsg, cmd),
								_1: {ctor: '[]'}
							});
				}
			case 'TimelineMsg':
				var _p19 = _p1._0;
				var cotoModal = model.cotoModal;
				var _p17 = A5(_user$project$Components_Timeline_Update$update, model.clientId, model.cotonoma, model.ctrlDown, _p19, model.timeline);
				var timeline = _p17._0;
				var cmd = _p17._1;
				var _p18 = _p19;
				switch (_p18.ctor) {
					case 'PostClick':
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{
									timeline: timeline,
									activeCotoId: A2(_user$project$App_Update$newActiveCotoId, model.activeCotoId, _p18._0)
								}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$TimelineMsg, cmd),
								_1: {ctor: '[]'}
							});
					case 'PostOpen':
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{
									timeline: timeline,
									cotoModal: _elm_lang$core$Native_Utils.update(
										cotoModal,
										{
											open: true,
											coto: _user$project$Components_Timeline_Model$toCoto(_p18._0)
										})
								}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$TimelineMsg, cmd),
								_1: {ctor: '[]'}
							});
					case 'CotonomaClick':
						return A2(_user$project$App_Update$changeLocationToCotonoma, _p18._0, model);
					case 'CotonomaPushed':
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{timeline: timeline}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$TimelineMsg, cmd),
								_1: {
									ctor: '::',
									_0: _user$project$App_Commands$fetchRecentCotonomas,
									_1: {
										ctor: '::',
										_0: _user$project$App_Commands$fetchSubCotonomas(model.cotonoma),
										_1: {ctor: '[]'}
									}
								}
							});
					default:
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								model,
								{timeline: timeline}),
							{
								ctor: '::',
								_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$TimelineMsg, cmd),
								_1: {ctor: '[]'}
							});
				}
			case 'DeleteCoto':
				var _p20 = _p1._0;
				var timeline = model.timeline;
				var posts = timeline.posts;
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							timeline: _elm_lang$core$Native_Utils.update(
								timeline,
								{
									posts: A2(
										_elm_lang$core$List$filter,
										function (post) {
											return !A2(_user$project$Components_Timeline_Model$isSelfOrPostedIn, _p20, post);
										},
										posts)
								})
						}),
					_p20.asCotonoma ? {
						ctor: '::',
						_0: _user$project$App_Commands$fetchRecentCotonomas,
						_1: {
							ctor: '::',
							_0: _user$project$App_Commands$fetchSubCotonomas(model.cotonoma),
							_1: {ctor: '[]'}
						}
					} : {ctor: '[]'});
			case 'CotoDeleted':
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					model,
					{ctor: '[]'});
			case 'OpenCotonomaModal':
				var cotonomaModal = function () {
					var _p21 = model.session;
					if (_p21.ctor === 'Nothing') {
						return model.cotonomaModal;
					} else {
						return A3(
							_user$project$Components_CotonomaModal_Model$setDefaultMembers,
							_p21._0,
							_user$project$App_Model$getOwnerAndMembers(model),
							model.cotonomaModal);
					}
				}();
				return A2(
					_elm_lang$core$Platform_Cmd_ops['!'],
					_elm_lang$core$Native_Utils.update(
						model,
						{
							cotonomaModal: _elm_lang$core$Native_Utils.update(
								cotonomaModal,
								{open: true})
						}),
					{ctor: '[]'});
			case 'CotonomaModalMsg':
				var _p25 = _p1._0;
				var _p22 = model.session;
				if (_p22.ctor === 'Nothing') {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						model,
						{ctor: '[]'});
				} else {
					var _p23 = A6(_user$project$Components_CotonomaModal_Update$update, model.clientId, _p22._0, model.cotonoma, _p25, model.timeline, model.cotonomaModal);
					var cotonomaModal = _p23._0;
					var timeline = _p23._1;
					var cmd = _p23._2;
					var newModel = _elm_lang$core$Native_Utils.update(
						model,
						{cotonomaModal: cotonomaModal, timeline: timeline});
					var commands = {
						ctor: '::',
						_0: A2(_elm_lang$core$Platform_Cmd$map, _user$project$App_Messages$CotonomaModalMsg, cmd),
						_1: {ctor: '[]'}
					};
					var _p24 = _p25;
					if ((_p24.ctor === 'Posted') && (_p24._0.ctor === 'Ok')) {
						return A2(
							_elm_lang$core$Platform_Cmd_ops['!'],
							_elm_lang$core$Native_Utils.update(
								newModel,
								{cotonomasLoading: true}),
							A2(
								_elm_lang$core$List$append,
								{
									ctor: '::',
									_0: _user$project$App_Commands$fetchRecentCotonomas,
									_1: {
										ctor: '::',
										_0: _user$project$App_Commands$fetchSubCotonomas(model.cotonoma),
										_1: {ctor: '[]'}
									}
								},
								commands));
					} else {
						return A2(_elm_lang$core$Platform_Cmd_ops['!'], newModel, commands);
					}
				}
			default:
				return A2(_user$project$App_Update$changeLocationToCotonoma, _p1._0, model);
		}
	});

var _user$project$Components_AppHeader$navigationToggle = function (model) {
	return A2(
		_elm_lang$html$Html$a,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$classList(
				{
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'toggle-navigation', _1: true},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: 'hidden',
							_1: _user$project$App_Model$isNavigationEmpty(model)
						},
						_1: {ctor: '[]'}
					}
				}),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(_user$project$App_Messages$NavigationToggle),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$i,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('material-icons'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text(
						model.navigationOpen ? 'arrow_drop_up' : 'arrow_drop_down'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		});
};
var _user$project$Components_AppHeader$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('app-header'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('location'),
					_1: {ctor: '[]'}
				},
				function () {
					var _p0 = model.cotonoma;
					if (_p0.ctor === 'Nothing') {
						return {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$i,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('material-icons'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('home'),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: _user$project$Components_AppHeader$navigationToggle(model),
								_1: {ctor: '[]'}
							}
						};
					} else {
						return {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('to-home'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Events$onClick(_user$project$App_Messages$HomeClick),
										_1: {ctor: '[]'}
									}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$i,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('material-icons'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('home'),
											_1: {ctor: '[]'}
										}),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$i,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('material-icons'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('navigate_next'),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$span,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('cotonoma-name'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text(_p0._0.name),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: _user$project$Components_AppHeader$navigationToggle(model),
										_1: {ctor: '[]'}
									}
								}
							}
						};
					}
				}()),
			_1: {
				ctor: '::',
				_0: function () {
					var _p1 = model.session;
					if (_p1.ctor === 'Nothing') {
						return A2(
							_elm_lang$html$Html$span,
							{ctor: '[]'},
							{ctor: '[]'});
					} else {
						return A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('add-cotonoma'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$title('Add Cotonoma'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Events$onClick(_user$project$App_Messages$OpenCotonomaModal),
										_1: {ctor: '[]'}
									}
								}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$i,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('material-icons'),
										_1: {ctor: '[]'}
									},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text('add_circle_outline'),
										_1: {ctor: '[]'}
									}),
								_1: {ctor: '[]'}
							});
					}
				}(),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('user'),
							_1: {ctor: '[]'}
						},
						function () {
							var _p2 = model.session;
							if (_p2.ctor === 'Nothing') {
								return {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$a,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$title('Sign in'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Events$onClick(_user$project$App_Messages$OpenSigninModal),
												_1: {ctor: '[]'}
											}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$i,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('material-icons'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: _elm_lang$html$Html$text('perm_identity'),
													_1: {ctor: '[]'}
												}),
											_1: {ctor: '[]'}
										}),
									_1: {ctor: '[]'}
								};
							} else {
								return {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$a,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$title('Profile'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Events$onClick(_user$project$App_Messages$OpenProfileModal),
												_1: {ctor: '[]'}
											}
										},
										{
											ctor: '::',
											_0: A2(
												_elm_lang$html$Html$img,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('avatar'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$src(_p2._0.avatarUrl),
														_1: {ctor: '[]'}
													}
												},
												{ctor: '[]'}),
											_1: {ctor: '[]'}
										}),
									_1: {ctor: '[]'}
								};
							}
						}()),
					_1: {ctor: '[]'}
				}
			}
		});
};

var _user$project$Components_Cotonomas$view = function (cotonomas) {
	return A3(
		_elm_lang$html$Html_Keyed$node,
		'div',
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('cotonomas'),
			_1: {ctor: '[]'}
		},
		A2(
			_elm_lang$core$List$map,
			function (cotonoma) {
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Basics$toString(cotonoma.id),
					_1: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('coto-as-cotonoma'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onClick(
										_user$project$App_Messages$CotonomaClick(cotonoma.key)),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$i,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('material-icons'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('exit_to_app'),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$span,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('cotonoma-name'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: _elm_lang$html$Html$text(cotonoma.name),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						})
				};
			},
			_elm_lang$core$List$reverse(cotonomas)));
};

var _user$project$Components_Navigation$recentCotonomasNav = function (cotonomas) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('recent'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('navigation-title'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Recent'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: _user$project$Components_Cotonomas$view(cotonomas),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Components_Navigation$subCotonomasNav = function (cotonomas) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('sub'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$div,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('navigation-title'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Sub'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: _user$project$Components_Cotonomas$view(cotonomas),
				_1: {ctor: '[]'}
			}
		});
};
var _user$project$Components_Navigation$cotonomaNav = F2(
	function (members, cotonoma) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('members'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('navigation-title'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Members'),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: function () {
						var _p0 = cotonoma.owner;
						if (_p0.ctor === 'Nothing') {
							return A2(
								_elm_lang$html$Html$div,
								{ctor: '[]'},
								{ctor: '[]'});
						} else {
							var _p1 = _p0._0;
							return A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('amishi member owner'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$img,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('avatar'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$src(_p1.avatarUrl),
												_1: {ctor: '[]'}
											}
										},
										{ctor: '[]'}),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$span,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('name'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: _elm_lang$html$Html$text(_p1.displayName),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}
								});
						}
					}(),
					_1: {
						ctor: '::',
						_0: A3(
							_elm_lang$html$Html_Keyed$node,
							'div',
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('members'),
								_1: {ctor: '[]'}
							},
							A2(
								_elm_lang$core$List$map,
								function (member) {
									return {
										ctor: '_Tuple2',
										_0: _elm_lang$core$Basics$toString(member.id),
										_1: A2(
											_elm_lang$html$Html$div,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('amishi member'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$img,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('avatar'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$src(member.avatarUrl),
															_1: {ctor: '[]'}
														}
													},
													{ctor: '[]'}),
												_1: {
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$span,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('name'),
															_1: {ctor: '[]'}
														},
														{
															ctor: '::',
															_0: _elm_lang$html$Html$text(member.displayName),
															_1: {ctor: '[]'}
														}),
													_1: {ctor: '[]'}
												}
											})
									};
								},
								members)),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _user$project$Components_Navigation$view = function (model) {
	return {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('navigation-content'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: function () {
					var _p2 = model.cotonoma;
					if (_p2.ctor === 'Nothing') {
						return A2(
							_elm_lang$html$Html$div,
							{ctor: '[]'},
							{ctor: '[]'});
					} else {
						return A2(_user$project$Components_Navigation$cotonomaNav, model.members, _p2._0);
					}
				}(),
				_1: {
					ctor: '::',
					_0: (!_elm_lang$core$List$isEmpty(model.subCotonomas)) ? _user$project$Components_Navigation$subCotonomasNav(model.subCotonomas) : A2(
						_elm_lang$html$Html$div,
						{ctor: '[]'},
						{ctor: '[]'}),
					_1: {
						ctor: '::',
						_0: _user$project$Components_Navigation$recentCotonomasNav(model.recentCotonomas),
						_1: {ctor: '[]'}
					}
				}
			}),
		_1: {ctor: '[]'}
	};
};

var _user$project$Components_ConfirmModal_View$modalConfig = function (model) {
	return {
		closeMessage: _user$project$Components_ConfirmModal_Messages$Close,
		title: 'Confirm',
		content: A2(
			_elm_lang$html$Html$div,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: _elm_lang$html$Html$text(model.message),
				_1: {ctor: '[]'}
			}),
		buttons: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$button,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('button'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Events$onClick(_user$project$Components_ConfirmModal_Messages$Close),
						_1: {ctor: '[]'}
					}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Cancel'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$button,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('button button-primary'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Events$onClick(_user$project$Components_ConfirmModal_Messages$Confirm),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('OK'),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		}
	};
};
var _user$project$Components_ConfirmModal_View$view = function (model) {
	return A2(
		_user$project$Modal$view,
		'confirm-modal',
		model.open ? _elm_lang$core$Maybe$Just(
			_user$project$Components_ConfirmModal_View$modalConfig(model)) : _elm_lang$core$Maybe$Nothing);
};

var _user$project$Components_Timeline_View$onClickWithoutPropagation = function (message) {
	var defaultOptions = _elm_lang$html$Html_Events$defaultOptions;
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'click',
		_elm_lang$core$Native_Utils.update(
			defaultOptions,
			{stopPropagation: true}),
		_elm_lang$core$Json_Decode$succeed(message));
};
var _user$project$Components_Timeline_View$onLoad = function (message) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'load',
		_elm_lang$core$Json_Decode$succeed(message));
};
var _user$project$Components_Timeline_View$onKeyDown = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'keydown',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$keyCode));
};
var _user$project$Components_Timeline_View$timelineClass = function (model) {
	return model.editingNew ? 'editing' : '';
};
var _user$project$Components_Timeline_View$customImageElement = function (image) {
	return A2(
		_elm_lang$html$Html$img,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$src(image.src),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$alt(image.alt),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$title(
						A2(_elm_lang$core$Maybe$withDefault, '', image.title)),
					_1: {
						ctor: '::',
						_0: _user$project$Components_Timeline_View$onLoad(_user$project$Components_Timeline_Messages$ImageLoaded),
						_1: {ctor: '[]'}
					}
				}
			}
		},
		{ctor: '[]'});
};
var _user$project$Components_Timeline_View$markdown = function (content) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('content'),
			_1: {ctor: '[]'}
		},
		A3(
			_user$project$Markdown$customHtml,
			_user$project$App_Markdown$markdownOptions,
			_elm_lang$core$Native_Utils.update(
				_user$project$App_Markdown$markdownElements,
				{image: _user$project$Components_Timeline_View$customImageElement}),
			content));
};
var _user$project$Components_Timeline_View$contentDiv = function (post) {
	return post.asCotonoma ? A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('coto-as-cotonoma'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$a,
				{
					ctor: '::',
					_0: _user$project$Components_Timeline_View$onClickWithoutPropagation(
						_user$project$Components_Timeline_Messages$CotonomaClick(post.cotonomaKey)),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$i,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('material-icons'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text('exit_to_app'),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$span,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('cotonoma-name'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(post.content),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		}) : _user$project$Components_Timeline_View$markdown(post.content);
};
var _user$project$Components_Timeline_View$authorDiv = F2(
	function (maybeSession, post) {
		var _p0 = maybeSession;
		if (_p0.ctor === 'Nothing') {
			return A2(
				_elm_lang$html$Html$span,
				{ctor: '[]'},
				{ctor: '[]'});
		} else {
			var _p1 = post.amishi;
			if (_p1.ctor === 'Nothing') {
				return A2(
					_elm_lang$html$Html$span,
					{ctor: '[]'},
					{ctor: '[]'});
			} else {
				var _p2 = _p1._0;
				return _elm_lang$core$Native_Utils.eq(_p2.id, _p0._0.id) ? A2(
					_elm_lang$html$Html$span,
					{ctor: '[]'},
					{ctor: '[]'}) : A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('amishi author'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$img,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('avatar'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$src(_p2.avatarUrl),
									_1: {ctor: '[]'}
								}
							},
							{ctor: '[]'}),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$span,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('name'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text(_p2.displayName),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					});
			}
		}
	});
var _user$project$Components_Timeline_View$isActive = F2(
	function (post, activeCotoId) {
		var _p3 = post.cotoId;
		if (_p3.ctor === 'Nothing') {
			return false;
		} else {
			return _elm_lang$core$Native_Utils.eq(
				A2(_elm_lang$core$Maybe$withDefault, -1, activeCotoId),
				_p3._0);
		}
	});
var _user$project$Components_Timeline_View$postDiv = F4(
	function (maybeSession, maybeCotonoma, activeCotoId, post) {
		var postedInAnother = !A2(_user$project$Components_Timeline_Model$isPostedInCotonoma, maybeCotonoma, post);
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'coto', _1: true},
						_1: {
							ctor: '::',
							_0: {
								ctor: '_Tuple2',
								_0: 'active',
								_1: A2(_user$project$Components_Timeline_View$isActive, post, activeCotoId)
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'posting',
									_1: _krisajenkins$elm_exts$Exts_Maybe$isJust(maybeSession) && _krisajenkins$elm_exts$Exts_Maybe$isNothing(post.cotoId)
								},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'being-hidden', _1: post.beingDeleted},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 'posted-in-another-cotonoma', _1: postedInAnother},
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: function () {
						var _p4 = post.cotoId;
						if (_p4.ctor === 'Nothing') {
							return _elm_lang$html$Html_Events$onClick(_user$project$Components_Timeline_Messages$NoOp);
						} else {
							return _elm_lang$html$Html_Events$onClick(
								_user$project$Components_Timeline_Messages$PostClick(_p4._0));
						}
					}(),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('border'),
						_1: {ctor: '[]'}
					},
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: function () {
						var _p5 = post.cotoId;
						if (_p5.ctor === 'Nothing') {
							return A2(
								_elm_lang$html$Html$span,
								{ctor: '[]'},
								{ctor: '[]'});
						} else {
							return A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('open-coto'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$title('Open coto view'),
										_1: {
											ctor: '::',
											_0: _user$project$Components_Timeline_View$onClickWithoutPropagation(
												_user$project$Components_Timeline_Messages$PostOpen(post)),
											_1: {ctor: '[]'}
										}
									}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$i,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('material-icons'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: _elm_lang$html$Html$text('open_in_new'),
											_1: {ctor: '[]'}
										}),
									_1: {ctor: '[]'}
								});
						}
					}(),
					_1: {
						ctor: '::',
						_0: function () {
							var _p6 = post.postedIn;
							if (_p6.ctor === 'Nothing') {
								return A2(
									_elm_lang$html$Html$span,
									{ctor: '[]'},
									{ctor: '[]'});
							} else {
								var _p7 = _p6._0;
								return postedInAnother ? A2(
									_elm_lang$html$Html$a,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('posted-in'),
										_1: {
											ctor: '::',
											_0: _user$project$Components_Timeline_View$onClickWithoutPropagation(
												_user$project$Components_Timeline_Messages$CotonomaClick(_p7.key)),
											_1: {ctor: '[]'}
										}
									},
									{
										ctor: '::',
										_0: _elm_lang$html$Html$text(_p7.name),
										_1: {ctor: '[]'}
									}) : A2(
									_elm_lang$html$Html$span,
									{ctor: '[]'},
									{ctor: '[]'});
							}
						}(),
						_1: {
							ctor: '::',
							_0: A2(_user$project$Components_Timeline_View$authorDiv, maybeSession, post),
							_1: {
								ctor: '::',
								_0: _user$project$Components_Timeline_View$contentDiv(post),
								_1: {ctor: '[]'}
							}
						}
					}
				}
			});
	});
var _user$project$Components_Timeline_View$getKey = function (post) {
	var _p8 = post.cotoId;
	if (_p8.ctor === 'Just') {
		return _elm_lang$core$Basics$toString(_p8._0);
	} else {
		var _p9 = post.postId;
		if (_p9.ctor === 'Just') {
			return _elm_lang$core$Basics$toString(_p9._0);
		} else {
			return '';
		}
	}
};
var _user$project$Components_Timeline_View$timelineDiv = F4(
	function (model, maybeSession, maybeCotonoma, activeCotoId) {
		return A3(
			_elm_lang$html$Html_Keyed$node,
			'div',
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('timeline'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$classList(
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'loading', _1: model.loading},
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			},
			A2(
				_elm_lang$core$List$map,
				function (post) {
					return {
						ctor: '_Tuple2',
						_0: _user$project$Components_Timeline_View$getKey(post),
						_1: A4(_user$project$Components_Timeline_View$postDiv, maybeSession, maybeCotonoma, activeCotoId, post)
					};
				},
				_elm_lang$core$List$reverse(model.posts)));
	});
var _user$project$Components_Timeline_View$view = F4(
	function (model, maybeSession, maybeCotonoma, activeCotoId) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id('input-and-timeline'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class(
						_user$project$Components_Timeline_View$timelineClass(model)),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A4(_user$project$Components_Timeline_View$timelineDiv, model, maybeSession, maybeCotonoma, activeCotoId),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$id('new-coto'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('toolbar'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$hidden(!model.editingNew),
										_1: {ctor: '[]'}
									}
								},
								{
									ctor: '::',
									_0: function () {
										var _p10 = maybeSession;
										if (_p10.ctor === 'Nothing') {
											return A2(
												_elm_lang$html$Html$span,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('user anonymous'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$i,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('material-icons'),
															_1: {ctor: '[]'}
														},
														{
															ctor: '::',
															_0: _elm_lang$html$Html$text('perm_identity'),
															_1: {ctor: '[]'}
														}),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html$text('Anonymous'),
														_1: {ctor: '[]'}
													}
												});
										} else {
											var _p11 = _p10._0;
											return A2(
												_elm_lang$html$Html$span,
												{
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$class('user session'),
													_1: {ctor: '[]'}
												},
												{
													ctor: '::',
													_0: A2(
														_elm_lang$html$Html$img,
														{
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$class('avatar'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$src(_p11.avatarUrl),
																_1: {ctor: '[]'}
															}
														},
														{ctor: '[]'}),
													_1: {
														ctor: '::',
														_0: A2(
															_elm_lang$html$Html$span,
															{
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$class('name'),
																_1: {ctor: '[]'}
															},
															{
																ctor: '::',
																_0: _elm_lang$html$Html$text(_p11.displayName),
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													}
												});
										}
									}(),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$div,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('tool-buttons'),
												_1: {ctor: '[]'}
											},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$button,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('button-primary'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$disabled(
																_user$project$Utils$isBlank(model.newContent)),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Events$onMouseDown(_user$project$Components_Timeline_Messages$Post),
																_1: {ctor: '[]'}
															}
														}
													},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('Post'),
														_1: {
															ctor: '::',
															_0: A2(
																_elm_lang$html$Html$span,
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html_Attributes$class('shortcut-help'),
																	_1: {ctor: '[]'}
																},
																{
																	ctor: '::',
																	_0: _elm_lang$html$Html$text('(Ctrl + Enter)'),
																	_1: {ctor: '[]'}
																}),
															_1: {ctor: '[]'}
														}
													}),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$textarea,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('coto'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$placeholder('Write your idea in Markdown'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$value(model.newContent),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Events$onFocus(_user$project$Components_Timeline_Messages$EditorFocus),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Events$onBlur(_user$project$Components_Timeline_Messages$EditorBlur),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Events$onInput(_user$project$Components_Timeline_Messages$EditorInput),
															_1: {
																ctor: '::',
																_0: _user$project$Components_Timeline_View$onKeyDown(_user$project$Components_Timeline_Messages$EditorKeyDown),
																_1: {ctor: '[]'}
															}
														}
													}
												}
											}
										}
									},
									{ctor: '[]'}),
								_1: {ctor: '[]'}
							}
						}),
					_1: {ctor: '[]'}
				}
			});
	});

var _user$project$Components_CotonomaModal_View$nameMaxlength = 30;
var _user$project$Components_CotonomaModal_View$validateName = function (string) {
	return (!_user$project$Utils$isBlank(string)) && (_elm_lang$core$Native_Utils.cmp(
		_elm_lang$core$String$length(string),
		_user$project$Components_CotonomaModal_View$nameMaxlength) < 1);
};
var _user$project$Components_CotonomaModal_View$memberAsAmishi = F2(
	function (isOwner, amishi) {
		return A2(
			_elm_lang$html$Html$li,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'amishi', _1: true},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'owner', _1: isOwner},
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$img,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('avatar'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$src(amishi.avatarUrl),
							_1: {ctor: '[]'}
						}
					},
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('name'),
							_1: {ctor: '[]'}
						},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(amishi.displayName),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: isOwner ? A2(
							_elm_lang$html$Html$span,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('owner-help'),
								_1: {ctor: '[]'}
							},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text('(owner)'),
								_1: {ctor: '[]'}
							}) : A2(
							_elm_lang$html$Html$a,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$class('remove-member'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Events$onClick(
										_user$project$Components_CotonomaModal_Messages$RemoveMember(amishi.email)),
									_1: {ctor: '[]'}
								}
							},
							{
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$i,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$class('fa fa-times'),
										_1: {
											ctor: '::',
											_0: A2(_elm_lang$html$Html_Attributes$attribute, 'aria-hidden', 'true'),
											_1: {ctor: '[]'}
										}
									},
									{ctor: '[]'}),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _user$project$Components_CotonomaModal_View$memberAsNotAmishi = function (email) {
	return A2(
		_elm_lang$html$Html$li,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('not-amishi'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$i,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('material-icons'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('perm_identity'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$span,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('email'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(email),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$a,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('remove-member'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(
									_user$project$Components_CotonomaModal_Messages$RemoveMember(email)),
								_1: {ctor: '[]'}
							}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$i,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('fa fa-times'),
									_1: {
										ctor: '::',
										_0: A2(_elm_lang$html$Html_Attributes$attribute, 'aria-hidden', 'true'),
										_1: {ctor: '[]'}
									}
								},
								{ctor: '[]'}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _user$project$Components_CotonomaModal_View$memberInputDiv = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('member-input'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$label,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Members'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$input,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$type_('text'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$class('u-full-width'),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$name('member'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$placeholder('Email address to invite'),
									_1: {
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$value(model.memberEmail),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Events$onInput(_user$project$Components_CotonomaModal_Messages$MemberEmailInput),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}
					},
					{ctor: '[]'}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$a,
						{
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$classList(
								{
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'add-member', _1: true},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 'disabled', _1: !model.memberEmailValid},
										_1: {ctor: '[]'}
									}
								}),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$title('Add member'),
								_1: {
									ctor: '::',
									_0: model.memberEmailValid ? _elm_lang$html$Html_Events$onClick(_user$project$Components_CotonomaModal_Messages$AddMember) : _elm_lang$html$Html_Events$onClick(_user$project$Components_CotonomaModal_Messages$NoOp),
									_1: {ctor: '[]'}
								}
							}
						},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$i,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$class('material-icons'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('add_circle_outline'),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _user$project$Components_CotonomaModal_View$modalConfig = F2(
	function (session, model) {
		return {
			closeMessage: _user$project$Components_CotonomaModal_Messages$Close,
			title: 'Cotonoma',
			content: A2(
				_elm_lang$html$Html$div,
				{ctor: '[]'},
				{
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$label,
								{ctor: '[]'},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Name'),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$input,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$type_('text'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('u-full-width'),
											_1: {
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$name('name'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$placeholder('Name'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$maxlength(_user$project$Components_CotonomaModal_View$nameMaxlength),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$value(model.name),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Events$onInput(_user$project$Components_CotonomaModal_Messages$NameInput),
																_1: {ctor: '[]'}
															}
														}
													}
												}
											}
										}
									},
									{ctor: '[]'}),
								_1: {ctor: '[]'}
							}
						}),
					_1: {
						ctor: '::',
						_0: _user$project$Components_CotonomaModal_View$memberInputDiv(model),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$classList(
										{
											ctor: '::',
											_0: {ctor: '_Tuple2', _0: 'members', _1: true},
											_1: {
												ctor: '::',
												_0: {ctor: '_Tuple2', _0: 'loading', _1: model.membersLoading},
												_1: {ctor: '[]'}
											}
										}),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$ul,
										{
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$class('members'),
											_1: {ctor: '[]'}
										},
										{
											ctor: '::',
											_0: A2(
												_user$project$Components_CotonomaModal_View$memberAsAmishi,
												true,
												_user$project$App_Types$toAmishi(session)),
											_1: A2(
												_elm_lang$core$List$map,
												function (member) {
													var _p0 = member;
													if (_p0.ctor === 'SignedUp') {
														return A2(_user$project$Components_CotonomaModal_View$memberAsAmishi, false, _p0._0);
													} else {
														return _user$project$Components_CotonomaModal_View$memberAsNotAmishi(_p0._0);
													}
												},
												model.members)
										}),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}
				}),
			buttons: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$button,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('button button-primary'),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$disabled(
								!_user$project$Components_CotonomaModal_View$validateName(model.name)),
							_1: {
								ctor: '::',
								_0: _elm_lang$html$Html_Events$onClick(_user$project$Components_CotonomaModal_Messages$Post),
								_1: {ctor: '[]'}
							}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Create'),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		};
	});
var _user$project$Components_CotonomaModal_View$view = F2(
	function (maybeSession, model) {
		return A2(
			_user$project$Modal$view,
			'cotonoma-modal',
			function () {
				var _p1 = maybeSession;
				if (_p1.ctor === 'Nothing') {
					return _elm_lang$core$Maybe$Nothing;
				} else {
					return model.open ? _elm_lang$core$Maybe$Just(
						A2(_user$project$Components_CotonomaModal_View$modalConfig, _p1._0, model)) : _elm_lang$core$Maybe$Nothing;
				}
			}());
	});

var _user$project$App_View$view = function (model) {
	var anyAnonymousCotos = _krisajenkins$elm_exts$Exts_Maybe$isNothing(model.session) && (!_elm_lang$core$List$isEmpty(model.timeline.posts));
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$id('app'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(
					{
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 'cotonomas-loading', _1: model.cotonomasLoading},
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _user$project$Components_AppHeader$view(model),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$id('app-body'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$div,
							{
								ctor: '::',
								_0: _elm_lang$html$Html_Attributes$id('navigation'),
								_1: {
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$classList(
										{
											ctor: '::',
											_0: {ctor: '_Tuple2', _0: 'neverToggled', _1: !model.navigationToggled},
											_1: {
												ctor: '::',
												_0: {
													ctor: '_Tuple2',
													_0: 'empty',
													_1: _user$project$App_Model$isNavigationEmpty(model)
												},
												_1: {
													ctor: '::',
													_0: {
														ctor: '_Tuple2',
														_0: 'notEmpty',
														_1: !_user$project$App_Model$isNavigationEmpty(model)
													},
													_1: {
														ctor: '::',
														_0: {ctor: '_Tuple2', _0: 'animated', _1: model.navigationToggled},
														_1: {
															ctor: '::',
															_0: {ctor: '_Tuple2', _0: 'slideInDown', _1: model.navigationToggled && model.navigationOpen},
															_1: {
																ctor: '::',
																_0: {ctor: '_Tuple2', _0: 'slideOutUp', _1: model.navigationToggled && (!model.navigationOpen)},
																_1: {ctor: '[]'}
															}
														}
													}
												}
											}
										}),
									_1: {ctor: '[]'}
								}
							},
							_user$project$Components_Navigation$view(model)),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$div,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$id('flow'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$map,
										_user$project$App_Messages$TimelineMsg,
										A4(_user$project$Components_Timeline_View$view, model.timeline, model.session, model.cotonoma, model.activeCotoId)),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$div,
									{
										ctor: '::',
										_0: _elm_lang$html$Html_Attributes$id('stock'),
										_1: {
											ctor: '::',
											_0: _elm_lang$html$Html_Attributes$classList(
												{
													ctor: '::',
													_0: {ctor: '_Tuple2', _0: 'hidden', _1: true},
													_1: {ctor: '[]'}
												}),
											_1: {ctor: '[]'}
										}
									},
									{ctor: '[]'}),
								_1: {ctor: '[]'}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$map,
						_user$project$App_Messages$ConfirmModalMsg,
						_user$project$Components_ConfirmModal_View$view(model.confirmModal)),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$map,
							_user$project$App_Messages$SigninModalMsg,
							A2(_user$project$Components_SigninModal$view, model.signinModal, anyAnonymousCotos)),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$map,
								_user$project$App_Messages$ProfileModalMsg,
								A2(_user$project$Components_ProfileModal$view, model.session, model.profileModal)),
							_1: {
								ctor: '::',
								_0: A2(
									_elm_lang$html$Html$map,
									_user$project$App_Messages$CotoModalMsg,
									_user$project$Components_CotoModal$view(model.cotoModal)),
								_1: {
									ctor: '::',
									_0: A2(
										_elm_lang$html$Html$map,
										_user$project$App_Messages$CotonomaModalMsg,
										A2(_user$project$Components_CotonomaModal_View$view, model.session, model.cotonomaModal)),
									_1: {
										ctor: '::',
										_0: A2(
											_elm_lang$html$Html$a,
											{
												ctor: '::',
												_0: _elm_lang$html$Html_Attributes$class('info-button'),
												_1: {
													ctor: '::',
													_0: _elm_lang$html$Html_Attributes$title('News and Feedback'),
													_1: {
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$href('https://twitter.com/cotoami'),
														_1: {
															ctor: '::',
															_0: _elm_lang$html$Html_Attributes$target('_blank'),
															_1: {
																ctor: '::',
																_0: _elm_lang$html$Html_Attributes$hidden(model.timeline.editingNew),
																_1: {ctor: '[]'}
															}
														}
													}
												}
											},
											{
												ctor: '::',
												_0: A2(
													_elm_lang$html$Html$i,
													{
														ctor: '::',
														_0: _elm_lang$html$Html_Attributes$class('material-icons'),
														_1: {ctor: '[]'}
													},
													{
														ctor: '::',
														_0: _elm_lang$html$Html$text('info'),
														_1: {ctor: '[]'}
													}),
												_1: {ctor: '[]'}
											}),
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}
				}
			}
		});
};

var _user$project$Main$init = F2(
	function (flags, location) {
		var route = _user$project$App_Routing$parseLocation(location);
		var initialModel = A2(_user$project$App_Model$initModel, flags.seed, route);
		var _p0 = function () {
			var _p1 = route;
			if (_p1.ctor === 'CotonomaRoute') {
				return A2(_user$project$App_Update$loadCotonoma, _p1._0, initialModel);
			} else {
				return _user$project$App_Update$loadHome(initialModel);
			}
		}();
		var model = _p0._0;
		var cmd = _p0._1;
		return A2(
			_elm_lang$core$Platform_Cmd_ops['!'],
			model,
			{
				ctor: '::',
				_0: _user$project$App_Commands$fetchSession,
				_1: {
					ctor: '::',
					_0: cmd,
					_1: {ctor: '[]'}
				}
			});
	});
var _user$project$Main$main = A2(
	_elm_lang$navigation$Navigation$programWithFlags,
	_user$project$App_Messages$OnLocationChange,
	{init: _user$project$Main$init, view: _user$project$App_View$view, update: _user$project$App_Update$update, subscriptions: _user$project$App_Subscriptions$subscriptions})(
	A2(
		_elm_lang$core$Json_Decode$andThen,
		function (seed) {
			return _elm_lang$core$Json_Decode$succeed(
				{seed: seed});
		},
		A2(_elm_lang$core$Json_Decode$field, 'seed', _elm_lang$core$Json_Decode$int)));
var _user$project$Main$Flags = function (a) {
	return {seed: a};
};

var Elm = {};
Elm['Main'] = Elm['Main'] || {};
if (typeof _user$project$Main$main !== 'undefined') {
    _user$project$Main$main(Elm['Main'], 'Main', {"types":{"unions":{"Dict.LeafColor":{"args":[],"tags":{"LBBlack":[],"LBlack":[]}},"Components.SigninModal.Msg":{"args":[],"tags":{"RequestClick":[],"Close":[],"EmailInput":["String"],"SaveAnonymousCotosCheck":["Bool"],"RequestDone":["Result.Result Http.Error String"]}},"Json.Encode.Value":{"args":[],"tags":{"Value":[]}},"Components.Timeline.Messages.Msg":{"args":[],"tags":{"CotonomaClick":["String"],"EditorFocus":[],"ImageLoaded":[],"Post":[],"PostsFetched":["Result.Result Http.Error (List Components.Timeline.Model.Post)"],"PostOpen":["Components.Timeline.Model.Post"],"EditorKeyDown":["Keyboard.KeyCode"],"EditorInput":["String"],"PostPushed":["Json.Encode.Value"],"CotonomaPushed":["Components.Timeline.Model.Post"],"EditorBlur":[],"PostClick":["Int"],"NoOp":[],"Posted":["Result.Result Http.Error Components.Timeline.Model.Post"]}},"App.Messages.Msg":{"args":[],"tags":{"OpenProfileModal":[],"CotonomaClick":["App.Types.CotonomaKey"],"RecentCotonomasFetched":["Result.Result Http.Error (List App.Types.Cotonoma)"],"OnLocationChange":["Navigation.Location"],"TimelineMsg":["Components.Timeline.Messages.Msg"],"CotoModalMsg":["Components.CotoModal.Msg"],"NavigationToggle":[],"SigninModalMsg":["Components.SigninModal.Msg"],"CotonomaFetched":["Result.Result Http.Error ( App.Types.Cotonoma , List App.Types.Amishi , List Components.Timeline.Model.Post )"],"KeyUp":["Keyboard.KeyCode"],"CotoDeleted":["Result.Result Http.Error String"],"OpenCotonomaModal":[],"KeyDown":["Keyboard.KeyCode"],"SubCotonomasFetched":["Result.Result Http.Error (List App.Types.Cotonoma)"],"ConfirmModalMsg":["Components.ConfirmModal.Messages.Msg"],"CotonomaModalMsg":["Components.CotonomaModal.Messages.Msg"],"SessionFetched":["Result.Result Http.Error App.Types.Session"],"OpenSigninModal":[],"DeleteCoto":["App.Types.Coto"],"NoOp":[],"ProfileModalMsg":["Components.ProfileModal.Msg"],"HomeClick":[]}},"Dict.Dict":{"args":["k","v"],"tags":{"RBNode_elm_builtin":["Dict.NColor","k","v","Dict.Dict k v","Dict.Dict k v"],"RBEmpty_elm_builtin":["Dict.LeafColor"]}},"Maybe.Maybe":{"args":["a"],"tags":{"Just":["a"],"Nothing":[]}},"Components.CotoModal.Msg":{"args":[],"tags":{"Close":[],"ConfirmDelete":["String"],"Delete":["App.Types.Coto"]}},"Dict.NColor":{"args":[],"tags":{"BBlack":[],"Red":[],"NBlack":[],"Black":[]}},"Components.CotonomaModal.Messages.Msg":{"args":[],"tags":{"AmishiFetched":["Result.Result Http.Error App.Types.Amishi"],"MemberEmailInput":["String"],"Post":[],"Close":[],"RemoveMember":["String"],"NoOp":[],"NameInput":["String"],"Posted":["Result.Result Http.Error Components.Timeline.Model.Post"],"AddMember":[]}},"Components.ConfirmModal.Messages.Msg":{"args":[],"tags":{"Confirm":[],"Close":[]}},"Components.ProfileModal.Msg":{"args":[],"tags":{"Close":[]}},"Http.Error":{"args":[],"tags":{"BadUrl":["String"],"NetworkError":[],"Timeout":[],"BadStatus":["Http.Response String"],"BadPayload":["String","Http.Response String"]}},"Result.Result":{"args":["error","value"],"tags":{"Ok":["value"],"Err":["error"]}}},"aliases":{"App.Types.Session":{"args":[],"type":"{ token : String , websocketUrl : String , id : Int , email : String , avatarUrl : String , displayName : String }"},"Http.Response":{"args":["body"],"type":"{ url : String , status : { code : Int, message : String } , headers : Dict.Dict String String , body : body }"},"App.Types.Amishi":{"args":[],"type":"{ id : Int , email : String , avatarUrl : String , displayName : String }"},"App.Types.Cotonoma":{"args":[],"type":"{ id : Int , key : App.Types.CotonomaKey , name : String , cotoId : Int , owner : Maybe.Maybe App.Types.Amishi }"},"Components.Timeline.Model.Post":{"args":[],"type":"{ postId : Maybe.Maybe Int , cotoId : Maybe.Maybe Int , content : String , amishi : Maybe.Maybe App.Types.Amishi , postedIn : Maybe.Maybe App.Types.Cotonoma , asCotonoma : Bool , cotonomaKey : String , beingDeleted : Bool }"},"Keyboard.KeyCode":{"args":[],"type":"Int"},"App.Types.CotonomaKey":{"args":[],"type":"String"},"App.Types.Coto":{"args":[],"type":"{ id : Int , content : String , postedIn : Maybe.Maybe App.Types.Cotonoma , asCotonoma : Bool , cotonomaKey : App.Types.CotonomaKey }"},"Navigation.Location":{"args":[],"type":"{ href : String , host : String , hostname : String , protocol : String , origin : String , port_ : String , pathname : String , search : String , hash : String , username : String , password : String }"}},"message":"App.Messages.Msg"},"versions":{"elm":"0.18.0"}});
}

if (typeof define === "function" && define['amd'])
{
  define([], function() { return Elm; });
  return;
}

if (typeof module === "object")
{
  module['exports'] = Elm;
  return;
}

var globalElm = this['Elm'];
if (typeof globalElm === "undefined")
{
  this['Elm'] = Elm;
  return;
}

for (var publicModule in Elm)
{
  if (publicModule in globalElm)
  {
    throw new Error('There are two Elm modules called `' + publicModule + '` on this page! Rename one of them.');
  }
  globalElm[publicModule] = Elm[publicModule];
}

}).call(this);

