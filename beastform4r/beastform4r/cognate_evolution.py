import numpy as np


def evolve_cognate(root, root_state, gain_rate, loss_rate, seed=None):
    """
    Simulate evolution of a single binary cognate.
    Returns states keyed by leaf name.
    """

    if seed is not None:
        np.random.seed(seed)

    states = {root: root_state}
    total_rate = gain_rate + loss_rate

    def evolve_branch(parent, child):
        parent_state = states[parent]
        t = child.branch_length

        if total_rate == 0:
            states[child] = parent_state
            return

        exp_term = np.exp(-total_rate * t)

        if parent_state == 0:
            p01 = (gain_rate / total_rate) * (1 - exp_term)
            states[child] = int(np.random.rand() < p01)
        else:
            p10 = (loss_rate / total_rate) * (1 - exp_term)
            states[child] = int(not (np.random.rand() < p10))

    def traverse(node):
        if node.left is not None:
            evolve_branch(node, node.left)
            traverse(node.left)
        if node.right is not None:
            evolve_branch(node, node.right)
            traverse(node.right)

    traverse(root)

    # Return only leaf states keyed by leaf name
    leaf_states = {}
    for node, state in states.items():
        if node.is_leaf():
            leaf_states[node.name] = state

    return leaf_states