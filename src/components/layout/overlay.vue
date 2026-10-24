<template>
    <section class="dot-bg h-screen w-screen fixed inset-0 -z-20 overflow-hidden">
        <div class="absolute top-[-10%] left-[5%] w-96 h-96 bg-blue-400/30 rounded-full blur-3xl"></div>
        <div class="absolute top-[20%] right-[5%] w-80 h-80 bg-indigo-400/20 rounded-full blur-3xl"></div>
        <div class="absolute bottom-[-15%] left-[30%] w-100 h-100 bg-sky-300/25 rounded-full blur-3xl"></div>
    </section>
</template>

<style scoped>
.dot-bg {
    background-image: radial-gradient(#cbd5e1 1.5px, transparent 1.5px);
    background-size: 24px 24px;
    background-color: #f8fafc;
}
</style>