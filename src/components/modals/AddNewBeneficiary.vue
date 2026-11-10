<script setup>
import { reactive, ref, watch } from 'vue'
import { X } from '@lucide/vue'
import { addBeneficiary, updateBeneficiary } from '../../services/Beneficiaries'
import { getLocalDateString } from '../../utils/dates'

const props = defineProps({
  IsOpen: Boolean,
  beneficiary: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'saved'])
const isSaving = ref(false)
const errorMessage = ref('')
const form = reactive({})

function resetForm() {
  Object.assign(form, {
    beneficiary_code: `BEN-${crypto.randomUUID().slice(0, 8).toUpperCase()}`,
    beneficiary_type: 'Regular',
    first_name: '',
    middle_name: '',
    last_name: '',
    suffix: '',
    birth_date: '',
    sex: '',
    contact_number: '',
    address: '',
    barangay: '',
    registration_date: getLocalDateString(),
    status: 'Active',
    eligibility: 'Pending'
  })
  errorMessage.value = ''
}

watch(() => [props.IsOpen, props.beneficiary], ([isOpen, beneficiary]) => {
  if (!isOpen) return
  resetForm()
  if (beneficiary) Object.assign(form, beneficiary)
})

async function saveBeneficiary() {
  if (!form.first_name.trim() || !form.last_name.trim()) {
    errorMessage.value = 'Ilagay ang first name at last name.'
    return
  }

  isSaving.value = true
  errorMessage.value = ''

  try {
    const payload = {
      beneficiary_code: form.beneficiary_code,
      beneficiary_type: form.beneficiary_type,
      first_name: form.first_name.trim(),
      middle_name: form.middle_name.trim(),
      last_name: form.last_name.trim(),
      suffix: form.suffix || null,
      birth_date: form.birth_date || null,
      sex: form.sex || null,
      registration_date: form.registration_date,
      status: form.status,
      eligibility: form.eligibility,
      contact_number: form.contact_number.trim() || null,
      address: form.address.trim() || null,
      barangay: form.barangay.trim() || null
    }
    const result = props.beneficiary
      ? await updateBeneficiary(props.beneficiary.beneficiary_id, payload)
      : await addBeneficiary(payload)

    if (result.error) throw result.error

    emit('saved', result.data)
    emit('close')
  } catch (error) {
    console.error('Error saving beneficiary:', error)
    errorMessage.value = error.message || 'Hindi na-save ang beneficiary. Subukan ulit.'
  } finally {
    isSaving.value = false
  }
}
</script>

<template>
  <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
    enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
    leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
    <section v-if="IsOpen" class="fixed inset-0 z-50 flex h-full w-full items-center justify-center bg-black/40 p-4">
      <form @submit.prevent="saveBeneficiary"
        class="max-h-[calc(100vh-2rem)] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 font-inter shadow-xl">
        <div class="flex items-start justify-between">
          <div>
            <h1 class="font-inter text-2xl font-bold text-[#404040]">
              {{ props.beneficiary ? 'Edit Beneficiary' : 'Add New Beneficiary' }}
            </h1>
            <p class="font-inter text-sm font-medium text-[#808080]">
              Register a beneficiary in your records.
            </p>
          </div>
          <button type="button" aria-label="Close" class="text-gray-400 transition hover:text-[#404040]"
            @click="emit('close')">
            <X :size="22" />
          </button>
        </div>

        <div class="mt-6 grid grid-cols-1 gap-6">
          <section class="grid gap-2">
            <h2 class="font-inter text-lg font-semibold text-[#404040]">Identity</h2>

            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">
                  First name <span class="text-red-500">*</span>
                </label>
                <input type="text" v-model="form.first_name"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="e.g. Juan" required>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Middle name</label>
                <input type="text" v-model="form.middle_name"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="Middle name">
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">
                  Last name <span class="text-red-500">*</span>
                </label>
                <input type="text" v-model="form.last_name"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="e.g. Dela Cruz" required>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Suffix</label>
                <select v-model="form.suffix"
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
                  <option value="">None</option>
                  <option>Jr.</option>
                  <option>Sr.</option>
                  <option>III</option>
                </select>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Beneficiary code</label>
                <input type="text" :value="form.beneficiary_code" readonly
                  class="w-full rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Beneficiary type</label>
                <select v-model="form.beneficiary_type"
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
                  <option>Regular</option>
                  <option>Senior</option>
                  <option>PWD</option>
                </select>
              </div>
            </div>
          </section>

          <section class="grid gap-2 border-t border-gray-100 pt-5">
            <h2 class="font-inter text-lg font-semibold text-[#404040]">Personal Details</h2>

            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-3">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Sex</label>
                <select v-model="form.sex"
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
                  <option value="">Select sex</option>
                  <option>Male</option>
                  <option>Female</option>
                </select>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Birth date</label>
                <input type="date" v-model="form.birth_date"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Registration date</label>
                <input type="date" v-model="form.registration_date" readonly
                  class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
              </div>
            </div>
            <div class="mt-1 grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Status</label>
                <select v-model="form.status"
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
                  <option>Active</option>
                  <option>Inactive</option>
                </select>
              </div>
            </div>
          </section>

          <section class="grid gap-2 border-t border-gray-100 pt-5">
            <h2 class="font-inter text-lg font-semibold text-[#404040]">Contact and Location</h2>

            <div class="mt-2 grid grid-cols-1 gap-3">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Address</label>
                <textarea v-model="form.address" rows="2"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="House number, street, and subdivision"></textarea>
              </div>
            </div>

            <div class="mt-1 grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Barangay</label>
                <input v-model="form.barangay" type="text"
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="Barangay">
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Contact number</label>
                <input type="tel" v-model="form.contact_number"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="e.g. 09XXXXXXXXX">
              </div>
            </div>
          </section>
        </div>

        <p v-if="errorMessage" role="alert" class="mt-4 text-sm text-red-600">{{ errorMessage }}</p>

        <div class="mt-6 flex flex-col-reverse justify-end gap-3 border-t border-gray-100 pt-4 sm:flex-row">
          <button type="button" :disabled="isSaving"
            class="rounded-lg border border-gray-200 px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50"
            @click="emit('close')">
            Cancel
          </button>
          <button type="submit" :disabled="isSaving"
            class="rounded-lg bg-blue-700 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-60">
            {{ isSaving ? 'Saving...' : (props.beneficiary ? 'Save Changes' : 'Save Beneficiary') }}
          </button>
        </div>
      </form>
    </section>
  </Transition>
</template>
