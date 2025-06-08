class PB_Benchmark : EventHandler
{
    int runs;
    array<double> samplesOfTime;

    /*
    uint lastRNG;

    override void OnRegister()
    {
        lastRNG = random();
        console.printf("PB_FastRNG: RNG seed set to %u", lastRNG);
    }

    int PB_GetRandomNumber()
    {
        uint state = lastRNG * 1664525u + 1013904223u;
        lastRNG = state;
        return lastRNG;
    }

    double PB_RandFloat()
    {
        return (PB_GetRandomNumber() - 2147483648) / 2147483648.f;
    }
    */

    void DoBench()
    {
        for(int i = 0; i < 512; i++)
        {
            runs++;
            double execTime = MSTimeF();

            for(int i = 0; i < 4096; i++) {
                frandom(-1, 1);
            }

            execTime = MSTimeF() - execTime;
            samplesOfTime.Push(execTime);
        }
        
        double averageOfTime;
        for(int i = 0; i < samplesOfTime.Size(); i++)
        {
            averageOfTime += samplesOfTime[i];
        }
        averageOfTime /= samplesOfTime.Size();

        console.printf("Benchmark ended.");
        console.printf("--- Results ---\nExecution time: %f\nSamples: %i", averageOfTime, runs);
    }
}