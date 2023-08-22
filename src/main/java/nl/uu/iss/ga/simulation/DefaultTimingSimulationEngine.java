package main.java.nl.uu.iss.ga.simulation;

import main.java.nl.uu.iss.ga.util.config.ArgParse;
import nl.uu.cs.iss.ga.sim2apl.core.deliberation.DeliberationResult;
import nl.uu.cs.iss.ga.sim2apl.core.platform.Platform;
import nl.uu.cs.iss.ga.sim2apl.core.tick.AbstractSimulationEngine;
import nl.uu.cs.iss.ga.sim2apl.core.tick.TickExecutor;
import nl.uu.cs.iss.ga.sim2apl.core.tick.TickHookProcessor;

import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.Future;

public class DefaultTimingSimulationEngine<T> extends AbstractSimulationEngine<T> {
    private final TickExecutor<T> executor;
    private final ArgParse arguments;

    public DefaultTimingSimulationEngine(Platform platform, ArgParse arguments, int nIterations, TickHookProcessor<T>... hookProcessors) {
        super(platform, nIterations, hookProcessors);
        this.executor = platform.getTickExecutor();
        this.arguments = arguments;

    }

    public boolean start() {
        if (this.nIterations <= 0) {
            while(true) {
                this.doTick();
            }
        } else {
            for (int i = 0; i < this.nIterations; ++i) {
                this.doTick();
            }
        }

        this.processSimulationFinishedHook(this.nIterations, this.executor.getLastTickDuration());
        this.executor.shutdown();
        return true;
    }

    private void doTick() {
        int tick = this.executor.getCurrentTick();

        HashMap<String, String> timingsMap = new HashMap<>();
        timingsMap.put("tick", Integer.toString(this.executor.getCurrentTick()));

        long millis = System.currentTimeMillis();
        this.processTickPreHooks(tick);
        timingsMap.put("prehook", Long.toString(System.currentTimeMillis() - millis));
        millis = System.currentTimeMillis();

        List<Future<DeliberationResult<T>>> agentActions = ((NoRescheduleBlockingTickExecutor<T>)this.executor).doTick(timingsMap);
        timingsMap.put("deliberation", Long.toString(System.currentTimeMillis() - millis));
        millis = System.currentTimeMillis();

        this.processTickPostHook(tick, this.executor.getLastTickDuration(), agentActions);
        timingsMap.put("posthook", Long.toString(System.currentTimeMillis() - millis));

    }
}
