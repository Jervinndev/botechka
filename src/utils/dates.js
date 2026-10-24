export function getLocalDateString(date = new Date()) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')

    return `${year}-${month}-${day}`
}

export function addDaysToDate(dateString, days) {
    if (!dateString) return ''

    const [year, month, day] = dateString.split('-').map(Number)
    const date = new Date(Date.UTC(year, month - 1, day + days))

    return date.toISOString().slice(0, 10)
}

export function getEarlierDate(firstDate, secondDate) {
    if (!firstDate) return secondDate
    if (!secondDate) return firstDate
    return firstDate < secondDate ? firstDate : secondDate
}

export function getLaterDate(firstDate, secondDate) {
    if (!firstDate) return secondDate
    if (!secondDate) return firstDate
    return firstDate > secondDate ? firstDate : secondDate
}
