
<template>
  <div class="mx-auto w-full max-w-[800px] overflow-hidden rounded-xl bg-white font-sans text-slate-800 shadow-lg">

    <!-- Header -->
    <div class="flex items-start justify-between px-[30px] pt-7 pb-4">
      <div>
        <h2 class="text-[19px] font-extrabold text-[#414141]">
          REGISTER BENEFICIARY
        </h2>
        <p class="mt-1 text-base text-gray-500">
          Add New Beneficiary
        </p>
      </div>

      <button
        type="button"
        class="flex h-[21px] w-[21px] items-center justify-center rounded-full border-2 border-gray-400 text-base leading-none text-gray-500"
      >
        ×
      </button>
    </div>

    <div class="px-[30px] pb-4">

      <!-- Identity -->
      <section>
        <h3 class="mb-4 mt-2 text-[13px] font-bold text-[#2938FF]">
          IDENTITY
        </h3>

        <div class="mb-[18px] grid grid-cols-1 gap-x-5 gap-y-4 sm:grid-cols-[1.1fr_1.1fr_1.1fr_0.52fr]">
          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              First name <span class="text-red-500">*</span>
            </label>
            <input
              type="text"
              value="Jervin"
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
            />
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Middle name
            </label>
            <input
              type="text"
              value="Anain"
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
            />
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Last name <span class="text-red-500">*</span>
            </label>
            <input
              type="text"
              value="Villones"
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
            />
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Suffix
            </label>
            <select
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-3 text-sm text-gray-500 outline-none"
            >
              <option>—</option>
              <option>Jr.</option>
              <option>Sr.</option>
              <option>III</option>
            </select>
          </div>
        </div>

        <div class="mb-4 grid grid-cols-1 gap-x-5 gap-y-4 sm:grid-cols-2">
          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Beneficiary ID
            </label>
            <input
              type="text"
              placeholder="—"
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
            />
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Beneficiary Type
            </label>
            <select
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm text-gray-500 outline-none"
            >
              <option>Senior Citizen</option>
              <option>PWD</option>
              <option>Indigent</option>
            </select>
          </div>
        </div>
      </section>

      <hr class="my-[15px] border-gray-200" />

      <!-- Personal Details -->
      <section>
        <h3 class="mb-4 mt-2 text-[13px] font-bold text-[#2938FF]">
          PERSONAL DETAILS
        </h3>

        <div class="mb-4 grid grid-cols-1 gap-x-5 gap-y-4 sm:grid-cols-3">
          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              SEX
            </label>
            <select
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm text-gray-500 outline-none"
            >
              <option>MALE</option>
              <option>FEMALE</option>
            </select>
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              BIRTH DATE
            </label>
            <input
              type="text"
              placeholder="▢   DD / MM / YYYY"
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
            />
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              AGE
            </label>
            <input
              type="text"
              value="67 years old"
              readonly
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm text-gray-500 outline-none"
            />
          </div>
        </div>
      </section>

      <hr class="my-[15px] border-gray-200" />

      <!-- Contact and Location -->
      <section>
        <h3 class="mb-4 mt-2 text-[13px] font-bold text-[#2938FF]">
          CONTACT AND LOCATION
        </h3>

        <div class="mb-4">
          <label class="mb-1 block text-[13px] font-semibold">
            Address
          </label>
          <input
            type="text"
            placeholder="—"
            class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
          />
        </div>

        <div class="grid grid-cols-1 gap-x-5 gap-y-4 sm:grid-cols-2">
          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Barangay
            </label>
            <select
              class="h-[41px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm text-gray-500 outline-none"
            >
              <option>—</option>
              <option>Calumpang</option>
              <option>Darangan</option>
              <option>Libid</option>
              <option>Poblacion</option>
            </select>
          </div>

          <div>
            <label class="mb-1 block text-[13px] font-semibold">
              Contact Number
            </label>
            <input
              type="tel"
              placeholder="e.g 09XXXXXXXXX"
              class="h-[46px] w-full rounded-[9px] border border-[#DCE4EF] bg-[#F7F9FB] px-[15px] text-sm outline-none focus:border-[#2938FF]"
            />
          </div>
        </div>
      </section>

      <!-- Footer -->
      <div class="mt-5 flex justify-end gap-3">
        <button
          type="button"
          class="h-10 w-[134px] rounded-[11px] border border-gray-200 bg-white text-[15px] text-gray-700 transition hover:bg-gray-50"
        >
          Cancel
        </button>

        <button
          type="button"
          class="h-10 w-[134px] rounded-[11px] bg-[#2938FF] text-[15px] text-white transition hover:bg-blue-700"
        >
          Save
        </button>
      </div>

    </div>
  </div>
</template>
