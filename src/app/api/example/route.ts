import { NextResponse } from "next/server";
import { getSupabase } from "@/lib/supabase";

export async function GET() {
  const supabase = getSupabase();
  // const { data, error } = await supabase.from("your_table").select("*");
  return NextResponse.json({ ok: true });
}
