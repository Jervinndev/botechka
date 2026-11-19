export function isWithinDateRange(value, range) {
    if (!Array.isArray(range) || !range[0] || !range[1]) return true

    const timestamp = new Date(value).getTime()
    if (Number.isNaN(timestamp)) return false

    const start = new Date(range[0]).getTime()
    const end = new Date(range[1]).getTime()

    return timestamp >= Math.min(start, end) && timestamp <= Math.max(start, end)
}
