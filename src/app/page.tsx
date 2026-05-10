import ThemeToggle from "@/components/ThemeToggle";

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center gap-6 p-8">
      <div className="absolute top-4 right-4">
        <ThemeToggle />
      </div>

      <h1 className="text-4xl font-bold tracking-tight uppercase">
        My App
      </h1>
      <p className="text-muted text-sm">
        Edit <code className="text-accent">src/app/page.tsx</code> to get started.
      </p>
    </main>
  );
}
