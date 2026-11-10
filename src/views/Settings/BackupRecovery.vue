<script setup>
import { computed, onMounted, ref } from 'vue'
import {
    DatabaseBackup, CalendarClock, Calendar, Cloud, HardDrive, Save,
    ShieldCheck, Database, ArrowRight, ArrowUpRight, Download, RotateCcw,
    CloudUpload, History, Eye, Info, ChevronDown, Lock, Upload, X
} from '@lucide/vue'
import {
    createDataBackup,
    downloadBackupFile,
    downloadCloudBackup,
    listCloudBackups,
    restoreDataBackup,
    uploadDataBackup,
    validateBackup
} from '../../services/BackupRecovery'

const settingsKey = 'botechka_backup_preferences'
const historyKey = 'botechka_backup_history'
const schedule = ref({ enabled: false, frequency: 'Every 24 hours', time: '06:00', cloud: false, local: true })
const backupHistory = ref([])
const cloudBackups = ref([])
const isLoading = ref(false)
const isRestoring = ref(false)
const message = ref('')
const errorMessage = ref('')
const selectedBackup = ref(null)
const selectedBackupName = ref('')

const latestBackupDate = computed(() => backupHistory.value[0]?.date || 'No backup created yet')

function saveHistory(item) {
    backupHistory.value = [item, ...backupHistory.value].slice(0, 100)
    localStorage.setItem(historyKey, JSON.stringify(backupHistory.value))
}

function formatDate(date) {
    if (!date) return '—'
    const parsedDate = new Date(date)
    return Number.isNaN(parsedDate.getTime()) ? '—' : parsedDate.toLocaleString()
}

function formatBytes(bytes) {
    if (!bytes) return '—'
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

function saveSchedule() {
    localStorage.setItem(settingsKey, JSON.stringify(schedule.value))
    message.value = 'Backup preferences saved on this browser.'
    errorMessage.value = ''
}

async function loadCloudBackups() {
    try {
        cloudBackups.value = await listCloudBackups()
    } catch (error) {
        console.error('Unable to load cloud backup list:', error)
        errorMessage.value = `Unable to load cloud backups: ${error.message}`
    }
}

async function createBackup() {
    if (isLoading.value || (!schedule.value.cloud && !schedule.value.local)) return
    isLoading.value = true
    message.value = ''
    errorMessage.value = ''
    let backup
    let downloaded = false
    try {
        backup = await createDataBackup()
        if (schedule.value.local) {
            downloadBackupFile(backup)
            downloaded = true
        }

        let destination = schedule.value.local ? 'Local download' : ''
        if (schedule.value.cloud) {
            const path = await uploadDataBackup(backup)
            destination = [destination, 'Private cloud storage'].filter(Boolean).join(' + ')
            await loadCloudBackups()
            saveHistory({
                date: backup.createdAt,
                type: 'Manual backup',
                destination,
                status: 'Success',
                size: new Blob([JSON.stringify(backup)]).size,
                cloudPath: path
            })
        } else {
            saveHistory({
                date: backup.createdAt,
                type: 'Manual backup',
                destination,
                status: 'Success',
                size: new Blob([JSON.stringify(backup)]).size
            })
        }
        message.value = `Backup completed: ${destination}.`
    } catch (error) {
        console.error('Backup failed:', error)
        if (backup && downloaded) {
            saveHistory({
                date: backup.createdAt,
                type: 'Manual backup',
                destination: 'Local download',
                status: 'Partial',
                size: new Blob([JSON.stringify(backup)]).size
            })
            errorMessage.value = `The local backup downloaded, but another backup step failed: ${error.message}`
        } else {
            errorMessage.value = error.message || 'Unable to create backup.'
        }
    } finally {
        isLoading.value = false
    }
}

async function handleBackupFileChange(event) {
    const file = event.target.files?.[0]
    event.target.value = ''
    if (!file) return

    errorMessage.value = ''
    message.value = ''
    try {
        const parsedBackup = JSON.parse(await file.text())
        validateBackup(parsedBackup)
        selectedBackup.value = parsedBackup
        selectedBackupName.value = file.name
    } catch (error) {
        console.error('Invalid backup selected:', error)
        errorMessage.value = error.message || 'Unable to read this backup file.'
    }
}

async function restoreSelectedBackup() {
    if (!selectedBackup.value || isRestoring.value) return
    isRestoring.value = true
    errorMessage.value = ''
    message.value = ''
    try {
        const restoredTables = await restoreDataBackup(selectedBackup.value)
        saveHistory({
            date: new Date().toISOString(),
            type: 'Restore from file',
            destination: selectedBackupName.value || 'Local recovery',
            status: 'Success',
            size: new Blob([JSON.stringify(selectedBackup.value)]).size
        })
        message.value = `Restore merged records for: ${restoredTables.join(', ') || 'no tables'}. Existing rows not included in the backup were kept.`
        selectedBackup.value = null
        selectedBackupName.value = ''
    } catch (error) {
        console.error('Backup restore failed:', error)
        errorMessage.value = error.message || 'Unable to restore this backup.'
    } finally {
        isRestoring.value = false
    }
}

async function restoreCloudBackup(path) {
    try {
        isLoading.value = true
        const backup = await downloadCloudBackup(path)
        selectedBackup.value = backup
        selectedBackupName.value = path.split('/').pop()
    } catch (error) {
        console.error('Unable to load cloud backup for restore:', error)
        errorMessage.value = error.message || 'Unable to open cloud backup.'
    } finally {
        isLoading.value = false
    }
}

function exportHistory() {
    const header = ['Date & time', 'Type', 'Destination', 'Status', 'Size']
    const rows = backupHistory.value.map((item) => [
        formatDate(item.date), item.type, item.destination, item.status, formatBytes(item.size)
    ])
    const csv = [header, ...rows]
        .map((row) => row.map((cell) => `"${String(cell ?? '').replaceAll('"', '""')}"`).join(','))
        .join('\r\n')
    const url = URL.createObjectURL(new Blob([`\uFEFF${csv}`], { type: 'text/csv;charset=utf-8' }))
    const link = document.createElement('a')
    link.href = url
    link.download = 'backup-history.csv'
    link.click()
    URL.revokeObjectURL(url)
}

onMounted(() => {
    try {
        const savedSchedule = JSON.parse(localStorage.getItem(settingsKey) || '{}')
        schedule.value = { ...schedule.value, ...savedSchedule }
        const savedHistory = JSON.parse(localStorage.getItem(historyKey) || '[]')
        backupHistory.value = Array.isArray(savedHistory) ? savedHistory : []
    } catch (error) {
        console.error('Unable to load backup settings:', error)
        errorMessage.value = 'Saved backup preferences or history could not be read.'
    }
    if (schedule.value.cloud) loadCloudBackups()
})
</script>

<template>
    <div class="min-h-screen font-sans text-slate-900">
        <header class="mb-5">
            <h1 class="flex items-center gap-2 text-xl font-bold">
                <DatabaseBackup :size="22" /> Backup &amp; Recovery
            </h1>
            <p class="mt-2 text-sm text-slate-600">
                <span>Last backup: <span class="font-semibold text-slate-900">{{ formatDate(latestBackupDate) }}</span></span>
            </p>
            <p class="mt-2 flex items-center gap-2 text-xs text-amber-700">
                <Info :size="15" /> Scheduled backups are saved as preferences only; this browser cannot run a backup while closed.
            </p>
        </header>

        <p v-if="message" role="status" class="mb-4 rounded-lg bg-emerald-50 p-3 text-sm text-emerald-700">{{ message }}</p>
        <p v-if="errorMessage" role="alert" class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>

        <section class="mb-5 rounded-2xl border border-slate-200 bg-white p-6">
            <div class="mb-5 flex items-start justify-between">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                        <CalendarClock :size="20" />
                    </span>
                    <div>
                        <h2 class="font-semibold">Backup preferences</h2>
                        <p class="text-xs text-slate-500">Choose destinations for a manual database backup.</p>
                    </div>
                </div>
                <label class="flex cursor-pointer items-center gap-2 text-xs font-medium text-slate-600">
                    Schedule preference
                    <input v-model="schedule.enabled" type="checkbox" class="peer sr-only">
                    <span class="relative h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-blue-600 after:absolute after:left-0.5 after:top-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:transition after:content-[''] peer-checked:after:translate-x-4"></span>
                </label>
            </div>

            <div class="mb-5 grid gap-4 md:grid-cols-2">
                <div>
                    <label class="mb-1.5 block text-xs font-semibold text-slate-700">Preferred frequency</label>
                    <div class="relative flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm">
                        <Calendar :size="16" class="text-slate-600" />
                        <select v-model="schedule.frequency" class="w-full appearance-none bg-transparent pr-6 outline-none">
                            <option>Every 12 hours</option>
                            <option>Every 24 hours</option>
                            <option>Every week</option>
                        </select>
                        <ChevronDown :size="14" class="pointer-events-none absolute right-3" />
                    </div>
                </div>
                <div>
                    <label for="backup-start-time" class="mb-1.5 block text-xs font-semibold text-slate-700">Preferred start time</label>
                    <input id="backup-start-time" v-model="schedule.time" type="time"
                        class="settings-picker w-full px-3 py-2.5 text-sm">
                </div>
            </div>

            <div class="flex flex-wrap items-center justify-between gap-4">
                <div class="flex items-center gap-6">
                    <label class="flex cursor-pointer items-center gap-2 text-sm text-slate-600">
                        <Cloud :size="18" class="text-blue-600" /> Private cloud
                        <input v-model="schedule.cloud" type="checkbox" class="peer sr-only">
                        <span class="relative h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-blue-600 after:absolute after:left-0.5 after:top-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:transition after:content-[''] peer-checked:after:translate-x-4"></span>
                    </label>
                    <label class="flex cursor-pointer items-center gap-2 text-sm text-slate-600">
                        <HardDrive :size="18" class="text-blue-600" /> Download
                        <input v-model="schedule.local" type="checkbox" class="peer sr-only">
                        <span class="relative h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-blue-600 after:absolute after:left-0.5 after:top-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:transition after:content-[''] peer-checked:after:translate-x-4"></span>
                    </label>
                </div>

                <div class="flex gap-2">
                    <button type="button" @click="saveSchedule"
                        class="flex items-center gap-2 rounded-lg border border-slate-200 px-4 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50">
                        <Save :size="16" /> Save preferences
                    </button>
                    <button type="button" @click="createBackup" :disabled="isLoading || (!schedule.cloud && !schedule.local)"
                        class="flex items-center gap-2 rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
                        <DatabaseBackup :size="16" /> {{ isLoading ? 'Creating...' : 'Create backup' }}
                    </button>
                </div>
            </div>
        </section>

        <section class="mb-5 rounded-2xl border border-slate-200 bg-white p-6">
            <div class="mb-5 flex items-start justify-between gap-4">
                <div>
                    <h2 class="font-semibold">Backup contents and recovery</h2>
                    <p class="text-xs text-slate-500">
                        Includes inventory, supplier, beneficiary, distribution, and medicine request records. Does not include Auth credentials or uploaded prescription/image files.
                    </p>
                </div>
                <span class="flex items-center gap-1.5 text-xs font-medium text-blue-600">
                    <ShieldCheck :size="14" /> Import uses merge; rows absent from backup are kept
                </span>
            </div>

            <div class="mb-4 grid items-center gap-3 md:grid-cols-[1fr_auto_1fr_auto_1fr]">
                <div class="flex items-center justify-between rounded-xl border border-slate-200 p-4">
                    <div class="flex items-center gap-3">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600"><Database :size="18" /></span>
                        <div><p class="text-sm font-semibold">Main database</p><p class="text-xs text-slate-500">Supabase tables</p></div>
                    </div>
                    <span class="rounded-full bg-blue-600 px-2.5 py-0.5 text-[10px] font-semibold text-white">Connected</span>
                </div>
                <ArrowRight :size="16" class="mx-auto text-slate-400" />
                <div class="flex items-center justify-between rounded-xl border border-slate-200 p-4">
                    <div class="flex items-center gap-3">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600"><Cloud :size="18" /></span>
                        <div><p class="text-sm font-semibold">Private cloud copy</p><p class="text-xs text-slate-500">Per-account storage</p></div>
                    </div>
                    <span class="rounded-full bg-blue-600 px-2.5 py-0.5 text-[10px] font-semibold text-white">{{ schedule.cloud ? 'Enabled' : 'Optional' }}</span>
                </div>
                <ArrowRight :size="16" class="mx-auto text-slate-400" />
                <div class="flex items-center justify-between rounded-xl border border-slate-200 p-4">
                    <div class="flex items-center gap-3">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600"><HardDrive :size="18" /></span>
                        <div><p class="text-sm font-semibold">Local recovery</p><p class="text-xs text-slate-500">JSON archive</p></div>
                    </div>
                    <span class="rounded-full bg-blue-600 px-2.5 py-0.5 text-[10px] font-semibold text-white">Available</span>
                </div>
            </div>

            <div class="grid gap-3 sm:grid-cols-2">
                <label class="flex cursor-pointer items-center justify-between rounded-xl border border-slate-200 p-4 text-left hover:border-blue-300 hover:bg-blue-50/40">
                    <span><span class="block text-sm font-semibold">Restore from file</span><span class="text-xs text-slate-500">Select a BOTECHKA JSON backup archive.</span></span>
                    <Upload :size="18" class="text-blue-600" />
                    <input type="file" accept=".json,application/json" class="sr-only" @change="handleBackupFileChange">
                </label>
                <button type="button" @click="loadCloudBackups" :disabled="isLoading"
                    class="rounded-xl border border-slate-200 p-4 text-left hover:border-blue-300 hover:bg-blue-50/40 disabled:opacity-50">
                    <div class="mb-2 flex items-start justify-between">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600"><CloudUpload :size="18" /></span>
                        <ArrowUpRight :size="16" class="text-blue-600" />
                    </div>
                    <p class="text-sm font-semibold">Refresh cloud backups</p>
                    <p class="text-xs text-slate-500">{{ cloudBackups.length }} archive(s) available</p>
                </button>
            </div>

            <div v-if="selectedBackup" class="mt-4 rounded-xl border border-amber-200 bg-amber-50 p-4">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <p class="text-sm font-semibold text-amber-900">Ready to restore {{ selectedBackupName }}</p>
                        <p class="mt-1 text-xs text-amber-800">
                            Backup date: {{ formatDate(selectedBackup.createdAt) }}. Matching rows may be overwritten; other rows will remain.
                        </p>
                    </div>
                    <button type="button" aria-label="Cancel restore" @click="selectedBackup = null"
                        class="rounded-md p-1 text-amber-800 hover:bg-amber-100"><X :size="18" /></button>
                </div>
                <button type="button" @click="restoreSelectedBackup" :disabled="isRestoring"
                    class="mt-3 flex items-center gap-2 rounded-lg bg-amber-700 px-4 py-2 text-sm font-semibold text-white hover:bg-amber-800 disabled:opacity-50">
                    <RotateCcw :size="15" /> {{ isRestoring ? 'Restoring...' : 'Confirm merge restore' }}
                </button>
            </div>

            <div v-if="cloudBackups.length" class="mt-4">
                <h3 class="mb-2 text-sm font-semibold text-slate-700">Cloud archives</h3>
                <ul class="divide-y divide-slate-100 rounded-lg border border-slate-200">
                    <li v-for="file in cloudBackups" :key="file.path" class="flex flex-wrap items-center justify-between gap-2 px-4 py-3">
                        <span class="text-sm text-slate-700">{{ file.name }} <span class="text-xs text-slate-400">{{ formatDate(file.createdAt) }} · {{ formatBytes(file.size) }}</span></span>
                        <button type="button" @click="restoreCloudBackup(file.path)"
                            class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-50">
                            <Eye :size="14" /> Select to restore
                        </button>
                    </li>
                </ul>
            </div>
        </section>

        <section class="overflow-hidden rounded-2xl border border-slate-200 bg-white">
            <div class="flex flex-wrap items-start justify-between gap-4 p-6 pb-4">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600"><History :size="20" /></span>
                    <div>
                        <h2 class="font-semibold">Backup history</h2>
                        <p class="text-xs text-slate-500">History is stored in this browser.</p>
                    </div>
                </div>
                <button type="button" @click="exportHistory"
                    class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50">
                    <Download :size="14" /> Export log
                </button>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full min-w-[800px] text-left text-sm">
                    <thead>
                        <tr class="border-y border-slate-200 bg-slate-50 text-[11px] font-semibold uppercase tracking-wide text-slate-500">
                            <th class="px-6 py-3">Date &amp; time</th>
                            <th class="px-6 py-3">Type</th>
                            <th class="px-6 py-3">Destination</th>
                            <th class="px-6 py-3">Status</th>
                            <th class="px-6 py-3">Size</th>
                            <th class="px-6 py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr v-if="!backupHistory.length">
                            <td colspan="6" class="px-6 py-8 text-center text-sm text-slate-500">No backup activity yet.</td>
                        </tr>
                        <tr v-for="(item, index) in backupHistory" :key="`${item.date}-${index}`" class="hover:bg-slate-50">
                            <td class="px-6 py-3">{{ formatDate(item.date) }}</td>
                            <td class="px-6 py-3">{{ item.type }}</td>
                            <td class="px-6 py-3">{{ item.destination }}</td>
                            <td class="px-6 py-3">
                                <span :class="item.status === 'Success' ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700'"
                                    class="inline-flex rounded-full px-3 py-1 text-xs font-semibold">{{ item.status }}</span>
                            </td>
                            <td class="px-6 py-3 text-slate-600">{{ formatBytes(item.size) }}</td>
                            <td class="px-6 py-3 text-center">
                                <button v-if="item.cloudPath" type="button" @click="restoreCloudBackup(item.cloudPath)"
                                    class="text-blue-600 hover:text-blue-800" aria-label="Restore this cloud backup">
                                    <RotateCcw :size="18" />
                                </button>
                                <Download v-else :size="17" class="mx-auto text-slate-300" />
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</template>
