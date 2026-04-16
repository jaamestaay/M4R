import numpy as np
# import matplotlib.pyplot as plt
import random
from .cognate_evolution import evolve_cognate
import pandas as pd


def yule_prior(n_leaves, birth_rate=1.0, seed=None):
    """
    Simulate an ultrametric phylogenetic tree under the Yule prior.
    ----------
    Parameters:
    n_leaves (int): Number of leaves in the tree.
    birth_rate (float): Birth rate for the tree generation, defaults to 1.0.
    seed (int, optional): Random seed for reproducibility, defaults to None.

    Returns:
    root (Node): Generated tree.
    ----------
    """

    if seed is not None:
        random.seed(seed)
        np.random.seed(seed)

    # Start at time 0 with one lineage
    root = Node(birth_time=0.0)
    active_lineages = [root]

    current_time = 0.0

    # Forward simulation
    while len(active_lineages) < n_leaves:
        k = len(active_lineages)
        wait_time = np.random.exponential(1.0 / (k * birth_rate))
        current_time += wait_time

        # choose lineage to split
        lineage = random.choice(active_lineages)

        # create children at current_time
        left = Node(parent=lineage, birth_time=current_time)
        right = Node(parent=lineage, birth_time=current_time)

        lineage.left = left
        lineage.right = right

        # branch length from parent = split_time - birth_time
        lineage.branch_length = current_time - lineage.birth_time

        # update active set
        active_lineages.remove(lineage)
        active_lineages.extend([left, right])

    # Final tree height
    total_height = current_time

    # Extend all remaining active lineages to total_height
    for leaf in active_lineages:
        leaf.branch_length = total_height - leaf.birth_time

    # Label leaves
    for i, leaf in enumerate(active_lineages):
        leaf.name = f"t{i+1}"

    return root


def birth_death_prior(n_leaves, birth_rate=1.0, death_rate=0.0, seed=None):
    """
    Simulate an ultrametric phylogenetic tree under the birthDeath prior.
    ----------
    Parameters:
    n_leaves (int): Number of leaves in the tree.
    birth_rate (float): Birth rate for the tree generation, defaults to 1.0.
    death_rate (float): Death rate for the tree generation, defaults to 0.0.
    seed (int, optional): Random seed for reproducibility, defaults to None.

    Returns:
    root (Node): Generated tree.
    ----------
    root : Node
    """

    if seed is not None:
        np.random.seed(seed)
        random.seed(seed)

    lam = birth_rate
    mu = death_rate

    if mu >= lam:
        raise ValueError("Require birth_rate > death_rate for a proper "
                         "BD prior.")

    deltas = []
    for k in range(2, n_leaves + 1):
        rate = (k - 1) * (lam - mu)
        deltas.append(np.random.exponential(1.0 / rate))

    # cumulative heights from present (0) backwards
    heights = np.cumsum(deltas)

    # 2) Initialize leaves at time 0
    leaves = [Node(birth_time=0.0) for _ in range(n_leaves)]
    for i, leaf in enumerate(leaves):
        leaf.name = f"t{i+1}"

    active = leaves[:]

    # 3) Build random ranked topology
    for h in heights:
        a, b = random.sample(active, 2)

        parent = Node(parent=None, birth_time=h)
        parent.left = a
        parent.right = b

        a.parent = parent
        b.parent = parent

        # branch lengths = parent time - child time
        a.branch_length = parent.birth_time - a.birth_time
        b.branch_length = parent.birth_time - b.birth_time

        active.remove(a)
        active.remove(b)
        active.append(parent)

    root = active[0]

    # root branch length conventionally 0
    root.branch_length = 0.0

    return root


class Node:
    """
    Tree Node class for representing phylogenetic trees.
    """
    def __init__(self, name=None, parent=None, birth_time=0.0):
        """
        Initialise tree node.
        ----------
        Parameters:
        name (str, optional): Name of the node, defaults to None.
        parent (Node, optional): Parent node, defaults to None.
        birth_time (float): Time of node birth, defaults to 0.0.
        ----------
        """
        self.name = name
        self.parent = parent
        self.left = None
        self.right = None
        self.birth_time = birth_time
        self.branch_length = 0.0

    def is_leaf(self):
        """
        Check if the node is a leaf (i.e., has no children).
        """
        return self.left is None and self.right is None

class Tree:
    """
    Tree class for representing phylogenetic trees, containing Nodes.
    """
    allowed_tree_methods = ['yule', 'birthDeath']
    
    def __init__(self, n_leaves, method='yule', birth_rate=1.0,
                      death_rate=0.0, seed=None):
        """
        Generate (ultrametric) tree with a specified number of leaves using a
        given method.
        ----------
        Parameters:
        n_leaves (int): Number of leaves in the tree.
        method (str): Method to generate the tree ('yule' or 'birthDeath').
        birth_rate (float): Birth rate for the tree generation,
            defaults to 1.0.
        death_rate (float): Death rate for the tree generation,
            defaults to 0.0.
        seed (int, optional): Random seed for reproducibility,
            defaults to None.
        ----------
        """
        self.seed = seed
        if method not in self.allowed_tree_methods:
            raise ValueError("Invalid method. Choose from "
                             f"{self.allowed_tree_methods}.")
        if method == 'yule':
            self.root = yule_prior(n_leaves, birth_rate, seed)
        elif method == 'birthDeath':
            self.root = birth_death_prior(n_leaves, birth_rate, death_rate,
                                         seed)
        self.method = method
        print(f"Generated {method} tree with {n_leaves} leaves.")
        
    # def plot(self):
    #     if self.root is None:
    #         raise ValueError("Tree is empty.")

    #     self._assign_y_positions()

    #     fig, ax = plt.subplots(figsize=(8, 5))
    #     self._plot_node(self.root, ax, 0)

    #     ax.invert_yaxis()
    #     ax.set_yticks([])
    #     ax.set_xlabel("Time / Branch length")

    #     plt.show()
    
    # def _plot_node(self, node, ax, x):
    #     if node is None:
    #         return

    #     x_end = x + node.branch_length

    #     # Draw horizontal branch
    #     ax.plot([x, x_end], [node.y, node.y], 'k-')

    #     if not node.is_leaf():
    #         # Draw vertical connector between children
    #         y_left = node.left.y
    #         y_right = node.right.y
    #         ax.plot([x_end, x_end], [y_left, y_right], 'k-')

    #         # Recurse
    #         self._plot_node(node.left, ax, x_end)
    #         self._plot_node(node.right, ax, x_end)
    #     else:
    #         # Label leaf
    #         ax.text(x_end + 0.1, node.y, node.name,
    #                 va='center')

    # def _assign_y_positions(self):
    #     """
    #     Assign y positions to leaves (evenly spaced).
    #     """
    #     self._y_counter = 0
    #     def dfs(node):
    #         if node.is_leaf():
    #             node.y = self._y_counter
    #             self._y_counter += 1
    #         else:
    #             dfs(node.left)
    #             dfs(node.right)
    #             node.y = (node.left.y + node.right.y) / 2
    #     dfs(self.root)

    def get_leaf_names(self):
        leaves = []
        def collect(node):
            if node.is_leaf():
                leaves.append(node.name)
            else:
                collect(node.left)
                collect(node.right)
        collect(self.root)
        self.leaves = leaves
        return leaves

    def generate_independent_data(self, n_sites,
                                gain_rate=0.4, loss_rate=0.6,
                                root_freq=0.3, ascertain=True):
        
        languages = self.get_leaf_names()
        rows = []

        for _ in range(n_sites):
            root_state = int(np.random.rand() < root_freq)
            states = evolve_cognate(self.root, root_state,
                                    gain_rate, loss_rate)
            rows.append([states[lang] for lang in languages])

        df = pd.DataFrame(rows, columns=languages)
        df.index = [f"cog_{i}" for i in range(len(df))]
        if ascertain:
            df = df.loc[df.sum(axis=1) > 0].copy()
        return df
        