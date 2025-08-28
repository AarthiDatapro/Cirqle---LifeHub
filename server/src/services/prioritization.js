/**
 * scoreTask(task) => numeric score (higher = more urgent/important)
 * Logic:
 * - baseScore from priority: high=40, medium=20, low=5
 * - dueDate: closer => add more weight (exponential decay)
 * - estimatedMinutes: shorter tasks slightly boosted to encourage quick wins
 */

const MS_IN_DAY = 1000 * 60 * 60 * 24;

function scoreTask(task) {
  let score = 0;
  const priorityMap = { high: 40, medium: 20, low: 5 };
  score += priorityMap[task.priority] || 10;

  if (task.dueDate) {
    const now = Date.now();
    const due = new Date(task.dueDate).getTime();
    const diffDays = (due - now) / MS_IN_DAY; // days until due (can be negative)
    // if overdue -> big penalty (i.e., higher score)
    if (diffDays <= 0) score += 50;
    else {
      // closer -> higher weight (non-linear)
      score += Math.max(0, 30 * Math.exp(-0.25 * diffDays));
    }
  }

  // shorter tasks get a small boost to encourage completion
  const est = task.estimatedMinutes || 30;
  if (est <= 15) score += 6;
  else if (est <= 60) score += 3;

  // completed tasks should be low priority
  if (task.completed) score = -100;

  return Math.round(score);
}

module.exports = { scoreTask };
